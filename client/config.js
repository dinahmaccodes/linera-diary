// Linera Configuration for Diary Application
export const config = {
    // Your application ID from deployment (update after deploying)
    applicationId: "YOUR_APPLICATION_ID_HERE",

    // Your chain ID from linera wallet show (update with your chain)
    chainId: "YOUR_CHAIN_ID_HERE",

    // Linera service endpoint (default port for linera service)
    serviceUrl: "http://localhost:8082",

    // GraphQL endpoint for your application (auto-generated)
    get graphqlUrl() {
        return `${this.serviceUrl}/chains/${this.chainId}/applications/${this.applicationId}`;
    },
};
