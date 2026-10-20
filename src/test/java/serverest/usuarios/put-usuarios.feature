@usuarios @put-usuarios
Feature: PUT /usuarios/{_id} - Actualizar usuario
  Como administrador del sistema
  Quiero actualizar la información de un usuario existente
  Para mantener la base de datos de usuarios al día

  Background:
    * url baseUrl
    * def cleanupIds = []
    * def mensagemSchema = read('classpath:serverest/common/schemas/mensagem-schema.json')
    * def cadastroSchema = read('classpath:serverest/common/schemas/cadastro-schema.json')
    * def created = call read('classpath:serverest/common/helpers/crear-usuario.feature') { user: '#(DataGenerator.newUser("true"))' }
    * eval karate.appendTo('cleanupIds', created.userId)

  @smoke @positive
  Scenario: Actualizar todos los datos de un usuario existente
    * def datosNuevos = DataGenerator.newUser('false')
    Given path 'usuarios', created.userId
    And request datosNuevos
    When method put
    Then status 200
    And match response == mensagemSchema
    And match response.message == 'Registro alterado com sucesso'

    # Los cambios quedaron persistidos
    Given path 'usuarios', created.userId
    When method get
    Then status 200
    And match response == karate.merge(datosNuevos, { _id: created.userId })

  @positive
  Scenario: Actualizar solo el nombre manteniendo el mismo email
    * def datosNuevos = karate.merge(created.payload, { nome: DataGenerator.randomName() })
    Given path 'usuarios', created.userId
    And request datosNuevos
    When method put
    Then status 200
    And match response == { message: 'Registro alterado com sucesso' }

    Given path 'usuarios', created.userId
    When method get
    Then status 200
    And match response.nome == datosNuevos.nome
    And match response.email == created.payload.email

  @positive
  Scenario: Actualizar un ID inexistente registra un usuario nuevo
    * def nuevoId = DataGenerator.randomId()
    * def payload = DataGenerator.newUser()
    Given path 'usuarios', nuevoId
    And request payload
    When method put
    Then status 201
    And match response == cadastroSchema
    * eval karate.appendTo('cleanupIds', response._id)

    Given path 'usuarios', response._id
    When method get
    Then status 200
    And match response.email == payload.email

  @negative
  Scenario: No se puede actualizar con un email que ya usa otro usuario
    * def otro = call read('classpath:serverest/common/helpers/crear-usuario.feature')
    * eval karate.appendTo('cleanupIds', otro.userId)
    * def datosNuevos = karate.merge(created.payload, { email: otro.payload.email })
    Given path 'usuarios', created.userId
    And request datosNuevos
    When method put
    Then status 400
    And match response == { message: 'Este email já está sendo usado' }

    # El usuario original no fue modificado
    Given path 'usuarios', created.userId
    When method get
    Then status 200
    And match response.email == created.payload.email

  @negative
  Scenario: No se puede actualizar enviando solo un campo
    Given path 'usuarios', created.userId
    And request { nome: 'Solo Nombre' }
    When method put
    Then status 400
    And match response ==
      """
      {
        email: 'email é obrigatório',
        password: 'password é obrigatório',
        administrador: 'administrador é obrigatório'
      }
      """

  @negative
  Scenario Outline: No se puede actualizar con datos inválidos - <caso>
    * def datosNuevos = DataGenerator.newUser()
    * set datosNuevos.<campo> = <valor>
    Given path 'usuarios', created.userId
    And request datosNuevos
    When method put
    Then status 400
    And match response == <respuesta>

    Examples:
      | caso                     | campo         | valor             | respuesta                                                      |
      | email sin formato válido | email         | 'correo-invalido' | { email: 'email deve ser um email válido' }                    |
      | nombre vacío             | nome          | ''                | { nome: 'nome não pode ficar em branco' }                      |
      | administrador inválido   | administrador | 'admin'           | { administrador: "administrador deve ser 'true' ou 'false'" }  |