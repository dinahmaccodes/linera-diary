// Linera Configuration for Diary Application
export const config = {
    // Your application ID from deployment (update after deploying)
    applicationId: "YOUR_APPLICATION_ID_HERE",

    // Your chain ID from deployment
    chainId: "1259e4132844b892fe0a1f7c687462d2aa15ad73b91fc53c8c734069b176168c",

    // Linera service endpoint (default port for linera service)
    // For local development: http://localhost:8080
    // For production: update with your deployed service URL
    serviceUrl: "http://localhost:8080",

    // GraphQL endpoint for your application (auto-generated)
    get graphqlUrl() {
        return `${this.serviceUrl}/chains/${this.chainId}/applications/${this.applicationId}`;
    },
};
