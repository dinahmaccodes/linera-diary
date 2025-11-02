export const config = {
  applicationId: "YOUR_APPLICATION_ID_HERE",
  chainId: "8fd4233c5d03554f87d47a711cf70619727ca3d148353446cab81fb56922c9b7",
  serviceUrl: "http://localhost:8080",

  get graphqlUrl() {
    return `${this.serviceUrl}/chains/${this.chainId}/applications/${this.applicationId}`;
  },
};
