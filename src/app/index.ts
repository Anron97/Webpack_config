export * from './environment';
export * from './app.component';
import * as services from './services/index';

const mapValuesToArray = (obj) => Object.keys(obj).map(key => obj[key]);

export const providers = [
    ...mapValuesToArray(services)
];
