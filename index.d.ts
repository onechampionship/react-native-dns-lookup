declare module 'react-native-dns-lookup' {
  export function getIpAddressesForHostname(hostname: string): Promise<ReadonlyArray<string>>;
  export function getCNameForHostname(hostname: string): Promise<Readonly<string>>;
}
