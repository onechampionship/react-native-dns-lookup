
import { NativeModules } from 'react-native';

const { RNDnsLookup } = NativeModules;

export function getIpAddressesForHostname(hostname) {
  return RNDnsLookup.getIpAddresses(hostname);
}
export function getCNameForHostname(hostname) {
  return RNDnsLookup.getCName(hostname);
}
