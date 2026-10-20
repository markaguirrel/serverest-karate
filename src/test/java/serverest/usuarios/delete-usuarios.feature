@usuarios @delete-usuarios
Feature: DELETE /usuarios/{_id} - Eliminar usuario
  Como administrador del sistema
  Quiero eliminar usuarios
  Para retirarlos de la base de datos de usuarios

  Background:
    * url baseUrl
    * def mensagemSchema = read('classpath:serverest/common/schemas/mensagem-schema.json')

  @smoke @positive
  Scenario: Eliminar un usuario existente
    * def created = call read('classpath:serverest/common/helpers/crear-usuario.feature')
    Given path 'usuarios', created.userId
    When method delete
    Then status 200
    And match response == mensagemSchema
    And match response.message == 'Registro excluído com sucesso'

    # El usuario ya no existe
    Given path 'usuarios', created.userId
    When method get
    Then status 400
    And match response == { message: 'Usuário não encontrado' }

  @negative
  Scenario: Eliminar un usuario inexistente no elimina ningún registro
    Given path 'usuarios', DataGenerator.randomId()
    When method delete
    Then status 200
    And match response == { message: 'Nenhum registro excluído' }

  @negative
  Scenario: Eliminar dos veces el mismo usuario
    * def created = call read('classpath:serverest/common/helpers/crear-usuario.feature')
    Given path 'usuarios', created.userId
    When method delete
    Then status 200
    And match response.message == 'Registro excluído com sucesso'

    Given path 'usuarios', created.userId
    When method delete
    Then status 200
    And match response == { message: 'Nenhum registro excluído' }

  @negative
  Scenario: No se puede eliminar un usuario que tiene un carrito registrado
    # Preparación: usuario administrador con sesión, un producto y un carrito
    * def created = call read('classpath:serverest/common/helpers/crear-usuario.feature') { user: '#(DataGenerator.newUser("true"))' }
    Given path 'login'
    And request { email: '#(created.payload.email)', password: '#(created.payload.password)' }
    When method post
    Then status 200
    * def token = response.authorization

    Given path 'produtos'
    And header Authorization = token
    And request DataGenerator.newProduct()
    When method post
    Then status 201
    * def productId = response._id

    Given path 'carrinhos'
    And header Authorization = token
    And request { produtos: [{ idProduto: '#(productId)', quantidade: 1 }] }
    When method post
    Then status 201
    * def cartId = response._id

    # Acción y validación
    Given path 'usuarios', created.userId
    When method delete
    Then status 400
    And match response == { message: 'Não é permitido excluir usuário com carrinho cadastrado', idCarrinho: '#(cartId)' }

    # Limpieza: cancelar el carrito, eliminar el producto y luego el usuario
    Given path 'carrinhos', 'cancelar-compra'
    And header Authorization = token
    When method delete
    Then status 200

    Given path 'produtos', productId
    And header Authorization = token
    When method delete
    Then status 200

    Given path 'usuarios', created.userId
    When method delete
    Then status 200
    And match response.message == 'Registro excluído com sucesso'