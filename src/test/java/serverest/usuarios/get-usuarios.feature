@usuarios @get-usuarios
Feature: GET /usuarios - Listar usuarios
  Como administrador del sistema
  Quiero obtener la lista de usuarios
  Para consultar la base de datos de usuarios

  Background:
    * url baseUrl
    * def cleanupIds = []
    * def usuarioSchema = read('classpath:serverest/common/schemas/usuario-schema.json')
    * def listaUsuariosSchema = read('classpath:serverest/common/schemas/lista-usuarios-schema.json')

  @smoke @positive
  Scenario: Listar todos los usuarios con estructura válida
    Given path 'usuarios'
    When method get
    Then status 200
    And match response == listaUsuariosSchema
    And match response.quantidade == response.usuarios.length

  @positive
  Scenario: El usuario recién registrado aparece en la lista filtrando por email
    * def created = call read('classpath:serverest/common/helpers/crear-usuario.feature')
    * eval karate.appendTo('cleanupIds', created.userId)
    Given path 'usuarios'
    And param email = created.payload.email
    When method get
    Then status 200
    And match response == listaUsuariosSchema
    And match response.quantidade == 1
    And match response.usuarios[0] == karate.merge(created.payload, { _id: created.userId })

  @positive
  Scenario Outline: Filtrar usuarios por tipo administrador = <administrador>
    * def created = call read('classpath:serverest/common/helpers/crear-usuario.feature') { user: '#(DataGenerator.newUser("<administrador>"))' }
    * eval karate.appendTo('cleanupIds', created.userId)
    Given path 'usuarios'
    And param administrador = '<administrador>'
    When method get
    Then status 200
    And match response == listaUsuariosSchema
    And match each response.usuarios contains { administrador: '<administrador>' }
    And match response.usuarios[*]._id contains created.userId

    Examples:
      | administrador |
      | true          |
      | false         |

  @positive
  Scenario: Filtrar por un email inexistente retorna una lista vacía
    Given path 'usuarios'
    And param email = DataGenerator.randomEmail()
    When method get
    Then status 200
    And match response == { quantidade: 0, usuarios: [] }

  @negative
  Scenario Outline: Filtrar con un parámetro inválido - <caso>
    Given path 'usuarios'
    And param <parametro> = '<valor>'
    When method get
    Then status 400
    And match response == <respuesta>

    Examples:
      | caso                        | parametro     | valor        | respuesta                                                            |
      | email con formato inválido  | email         | correo-malo  | { email: 'email deve ser um email válido' }                          |
      | administrador no booleano   | administrador | sim          | { administrador: "administrador deve ser 'true' ou 'false'" }        |
      | parámetro no permitido      | apellido      | Perez        | { apellido: 'apellido não é permitido' }                             |