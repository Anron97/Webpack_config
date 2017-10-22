class Environment {
    public serverUrl: string;
    public production: boolean;
}

const ENV = process.env.ENV;

const env = new Environment();
switch (ENV) {
    case 'dev':
        env.serverUrl = '';
        env.production = false;
        break;
    case 'production':
        env.serverUrl = '';
        env.production = true;
        break;
}

export const environment = env;
