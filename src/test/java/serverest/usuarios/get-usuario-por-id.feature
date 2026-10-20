@usuarios @get-usuario-por-id
Feature: GET /usuarios/{_id} - Buscar usuario por ID
  Como administrador del sistema
  Quiero buscar un usuario específico por su ID
  Para consultar su información

  Background:
    * url baseUrl
    * def cleanupIds = []
    * def usuarioSchema = read('classpath:serverest/common/schemas/usuario-schema.json')

  @smoke @positive
  Scenario: Buscar un usuario existente por su ID
    * def created = call read('classpath:serverest/common/helpers/crear-usuario.feature')
    * eval karate.appendTo('cleanupIds', created.userId)
    Given path 'usuarios', created.userId
    When method get
    Then status 200
    And match response == usuarioSchema
    And match response == karate.merge(created.payload, { _id: created.userId })
    And match response.email == '#regex ^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$'

  @negative
  Scenario: Buscar un ID con formato válido que no existe
    Given path 'usuarios', DataGenerator.randomId()
    When method get
    Then status 400
    And match response == { message: 'Usuário não encontrado' }

  @negative
  Scenario: Buscar un usuario que fue eliminado
    * def created = call read('classpath:serverest/common/helpers/crear-usuario.feature')
    Given path 'usuarios', created.userId
    When method delete
    Then status 200

    Given path 'usuarios', created.userId
    When method get
    Then status 400
    And match response == { message: 'Usuário não encontrado' }

  @negative
  Scenario Outline: Buscar con un ID de formato inválido - <caso>
    Given path 'usuarios', '<id>'
    When method get
    Then status 400
    And match response == { id: 'id deve ter exatamente 16 caracteres alfanuméricos' }

    Examples:
      | caso                        | id                 |
      | menos de 16 caracteres      | 123                |
      | más de 16 caracteres        | 12345678901234567  |
      | caracteres especiales       | @@@@@@@@@@@@@@@@   |