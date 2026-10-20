function fn() {
    var env = karate.env || 'public';
    karate.log('Ambiente de ejecución:', env);

    var config = {
        env: env,
        baseUrl: 'https://serverest.dev'
    };

    if (env === 'local') {
        config.baseUrl = 'http://localhost:3000';
    }

    // Generador de datos de prueba (Datafaker) disponible en todos los features
    config.DataGenerator = Java.type('serverest.common.data.DataGenerator');

    karate.configure('connectTimeout', 10000);
    karate.configure('readTimeout', 10000);
    karate.configure('logPrettyRequest', true);
    karate.configure('logPrettyResponse', true);

    // Limpieza: al terminar cada escenario se eliminan los usuarios que registró,
    // para no dejar datos basura en la API compartida
    karate.configure('afterScenario', function () {
        var ids = karate.get('cleanupIds');
        if (!ids) return;
        for (var i = 0; i < ids.length; i++) {
            karate.call('classpath:serverest/common/helpers/eliminar-usuario.feature', { id: ids[i] });
        }
    });

    return config;
}