Feature: Listar usuarios

  Background:
    * url baseUrl

  Scenario: Listar todos los usuarios
    Given path 'usuarios'
    When method get
    Then status 200