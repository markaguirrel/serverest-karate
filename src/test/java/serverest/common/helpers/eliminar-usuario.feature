@ignore
Feature: Helper - Eliminar un usuario de prueba (limpieza)

  # Uso: * call read('classpath:serverest/common/helpers/eliminar-usuario.feature') { id: '#(userId)' }
  # Se invoca automáticamente desde el afterScenario definido en karate-config.js

  Scenario: Eliminar usuario
    Given url baseUrl
    And path 'usuarios', id
    When method delete
    Then status 200