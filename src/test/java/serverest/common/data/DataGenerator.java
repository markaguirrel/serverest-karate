package serverest.common.data;

import net.datafaker.Faker;

import java.util.HashMap;
import java.util.Locale;
import java.util.Map;
import java.util.UUID;

/**
 * Generador de datos de prueba para la API de ServeRest.
 * Cada llamada produce datos nuevos, de modo que los escenarios son
 * independientes entre sí y pueden ejecutarse en paralelo.
 */
public class DataGenerator {

    private static final Faker faker = new Faker(Locale.forLanguageTag("pt-BR"));

    private DataGenerator() {
    }

    public static String randomName() {
        return faker.name().fullName();
    }

    /**
     * Email único: se usa UUID en lugar de Faker para garantizar que no se
     * repita, ya que la API pública es compartida y los tests corren en paralelo.
     */
    public static String randomEmail() {
        String unique = UUID.randomUUID().toString().replace("-", "").substring(0, 12);
        return "qa." + unique + "@serverest-test.com";
    }

    public static String randomPassword() {
        return faker.internet().password(8, 16);
    }

    /**
     * Id con formato válido (16 caracteres alfanuméricos) que no corresponde a
     * ningún usuario existente.
     */
    public static String randomId() {
        return UUID.randomUUID().toString().replace("-", "").substring(0, 16);
    }

    public static Map<String, Object> newUser(String administrador) {
        Map<String, Object> user = new HashMap<>();
        user.put("nome", randomName());
        user.put("email", randomEmail());
        user.put("password", randomPassword());
        user.put("administrador", administrador);
        return user;
    }

    public static Map<String, Object> newUser() {
        return newUser(String.valueOf(faker.bool().bool()));
    }

    public static Map<String, Object> newProduct() {
        Map<String, Object> product = new HashMap<>();
        product.put("nome", "Produto QA " + UUID.randomUUID().toString().substring(0, 8));
        product.put("preco", faker.number().numberBetween(10, 500));
        product.put("descricao", faker.lorem().sentence());
        product.put("quantidade", faker.number().numberBetween(5, 50));
        return product;
    }
}