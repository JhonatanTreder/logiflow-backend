export class EnvHandler {

    requireEnv(name: string): string {
        const value = process.env[name];

        if (!value) throw new Error(`Variável ${name} não encontrada no .env`);

        return value;
    }
}