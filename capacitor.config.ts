import { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'com.sportspulse.app',
  appName: 'SportsPulse',
  webDir: 'out',
  bundledWebRuntime: false,
  ios: {
    contentInset: 'automatic',
    backgroundColor: '#080C14',
    scheme: 'sportspulse',
    limitsNavigationsToAppBoundDomains: true,
  },
  android: {
    backgroundColor: '#080C14',
    allowMixedContent: false,
    captureInput: true,
    webContentsDebuggingEnabled: false,
  },
  plugins: {
    PushNotifications: {
      presentationOptions: ['badge', 'sound', 'alert'],
    },
    SplashScreen: {
      launchShowDuration: 2000,
      backgroundColor: '#080C14',
      showSpinner: false,
    },
  },
};

export default config;
