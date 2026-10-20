@usuarios @post-usuarios
Feature: POST /usuarios - Registrar usuario
  Como administrador del sistema
  Quiero registrar nuevos usuarios
  Para incorporarlos a la base de datos de usuarios

  Background:
    * url baseUrl
    * def cleanupIds = []
    * def cadastroSchema = read('classpath:serverest/common/schemas/cadastro-schema.json')
    * def usuarioSchema = read('classpath:serverest/common/schemas/usuario-schema.json')

  @smoke @positive
  Scenario Outline: Registrar un usuario válido con administrador = <administrador>
    * def payload = DataGenerator.newUser('<administrador>')
    Given path 'usuarios'
    And request payload
    When method post
    Then status 201
    And match response == cadastroSchema
    * def userId = response._id
    * eval karate.appendTo('cleanupIds', userId)

    # El usuario quedó persistido con los datos enviados
    Given path 'usuarios', userId
    When method get
    Then status 200
    And match response == usuarioSchema
    And match response == karate.merge(payload, { _id: userId })

    Examples:
      | administrador |
      | true          |
      | false         |

  @negative
  Scenario: No se puede registrar un usuario con un email ya registrado
    * def created = call read('classpath:serverest/common/helpers/crear-usuario.feature')
    * eval karate.appendTo('cleanupIds', created.userId)
    * def payload = DataGenerator.newUser()
    * set payload.email = created.payload.email
    Given path 'usuarios'
    And request payload
    When method post
    Then status 400
    And match response == { message: 'Este email já está sendo usado' }

  @negative
  Scenario Outline: No se puede registrar un usuario con el campo <campo> vacío
    * def payload = DataGenerator.newUser()
    * set payload.<campo> = ''
    Given path 'usuarios'
    And request payload
    When method post
    Then status 400
    And match response == { <campo>: "<mensaje>" }

    Examples:
      | campo         | mensaje                                   |
      | nome          | nome não pode ficar em branco             |
      | email         | email não pode ficar em branco            |
      | password      | password não pode ficar em branco         |
      | administrador | administrador deve ser 'true' ou 'false'  |

  @negative
  Scenario Outline: No se puede registrar un usuario sin el campo obligatorio <campo>
    * def payload = DataGenerator.newUser()
    * remove payload.<campo>
    Given path 'usuarios'
    And request payload
    When method post
    Then status 400
    And match response == { <campo>: '<campo> é obrigatório' }

    Examples:
      | campo         |
      | nome          |
      | email         |
      | password      |
      | administrador |

  @negative
  Scenario: No se puede registrar un usuario con el body vacío
    Given path 'usuarios'
    And request {}
    When method post
    Then status 400
    And match response ==
      """
      {
        nome: 'nome é obrigatório',
        email: 'email é obrigatório',
        password: 'password é obrigatório',
        administrador: 'administrador é obrigatório'
      }
      """

  @negative
  Scenario Outline: No se puede registrar un usuario con datos inválidos - <caso>
    * def payload = DataGenerator.newUser()
    * set payload.<campo> = <valor>
    Given path 'usuarios'
    And request payload
    When method post
    Then status 400
    And match response == <respuesta>

    Examples:
      | caso                               | campo         | valor             | respuesta                                                       |
      | email sin formato válido           | email         | 'correo-invalido' | { email: 'email deve ser um email válido' }                     |
      | email sin dominio                  | email         | 'qa@'             | { email: 'email deve ser um email válido' }                     |
      | administrador con texto no válido  | administrador | 'sim'             | { administrador: "administrador deve ser 'true' ou 'false'" }   |
      | administrador como booleano        | administrador | true              | { administrador: "administrador deve ser 'true' ou 'false'" }   |

  @negative
  Scenario: No se puede registrar un usuario con un campo no permitido
    * def payload = DataGenerator.newUser()
    * set payload.telefono = '999888777'
    Given path 'usuarios'
    And request payload
    When method post
    Then status 400
    And match response == { telefono: 'telefono não é permitido' }