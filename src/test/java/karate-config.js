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

    karate.configure('connectTimeout', 10000);
    karate.configure('readTimeout', 10000);
    karate.configure('logPrettyRequest', true);
    karate.configure('logPrettyResponse', true);

    return config;
}