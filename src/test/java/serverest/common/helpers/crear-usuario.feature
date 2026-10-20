@ignore
Feature: Helper - Registrar un usuario de prueba

  # Uso:
  #   * def created = call read('classpath:serverest/common/helpers/crear-usuario.feature')
  #   * def created = call read('classpath:serverest/common/helpers/crear-usuario.feature') { user: '#(miUsuario)' }
  # Retorna: created.userId, created.payload

  Scenario: Registrar usuario
    * def payload = karate.get('user', DataGenerator.newUser())
    Given url baseUrl
    And path 'usuarios'
    And request payload
    When method post
    Then status 201
    * def userId = response._id