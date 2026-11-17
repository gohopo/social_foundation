import {
  AbilityAware,
  AbilityPluginBinding,
  FlutterPlugin,
  FlutterPluginBinding,
  Log,
  MethodCall,
  MethodCallHandler,
  MethodChannel,
  MethodResult,
} from '@ohos/flutter_ohos';
import UIAbility from '@ohos.app.ability.UIAbility';
import { abilityAccessCtrl, PermissionRequestResult, Permissions } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { identifier } from '@kit.AdsKit';

const TAG: string = "SocialFoundationPlugin";
const TRACKING_PERMISSION: Permissions = 'ohos.permission.APP_TRACKING_CONSENT';
// The system returns this GUID when the permission is not configured or the user
// disallowed cross-app association, so it carries no device identity.
const EMPTY_OAID: string = '00000000-0000-0000-0000-000000000000';

/** SocialFoundationPlugin **/
export default class SocialFoundationPlugin implements FlutterPlugin, MethodCallHandler, AbilityAware {
  private channel: MethodChannel | null = null;
  private ability: UIAbility | null = null;
  // The consent dialog is only shown once per engine process; later calls reuse the outcome.
  private consentRequest: Promise<boolean> | null = null;

  constructor() {
  }

  getUniqueClassName(): string {
    return "SocialFoundationPlugin"
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.channel = new MethodChannel(binding.getBinaryMessenger(), "social_foundation");
    this.channel.setMethodCallHandler(this)
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    if (this.channel != null) {
      this.channel.setMethodCallHandler(null)
    }
  }

  onAttachedToAbility(binding: AbilityPluginBinding): void {
    this.ability = binding.getAbility();
  }

  onDetachedFromAbility(): void {
    this.ability = null;
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    if (call.method == "getPlatformVersion") {
      result.success("OpenHarmony ^ ^ ")
    } else if (call.method == "getOAID") {
      this.handleGetOAID(result);
    } else {
      result.notImplemented()
    }
  }

  private async handleGetOAID(result: MethodResult): Promise<void> {
    try {
      const granted: boolean = await this.ensureTrackingConsent();
      if (!granted) {
        Log.w(TAG, 'APP_TRACKING_CONSENT was not granted, OAID is unavailable');
        result.success(null);
        return;
      }
      const oaid: string = await identifier.getOAID();
      if (oaid.length == 0 || oaid == EMPTY_OAID) {
        Log.w(TAG, 'OAID is empty or all-zero, treating it as unavailable');
        result.success(null);
        return;
      }
      result.success(oaid);
    } catch (error) {
      const err = error as BusinessError;
      Log.e(TAG, `getOAID failed: ${err.code} ${err.message}`);
      result.success(null);
    }
  }

  private ensureTrackingConsent(): Promise<boolean> {
    if (this.consentRequest == null) {
      this.consentRequest = this.requestTrackingConsent();
    }
    return this.consentRequest;
  }

  private async requestTrackingConsent(): Promise<boolean> {
    const ability = this.ability;
    if (ability == null) {
      // No UIAbility is attached, so no dialog can be shown. The OAID may still
      // be readable when the permission was granted in an earlier session.
      return true;
    }
    try {
      const atManager = abilityAccessCtrl.createAtManager();
      const permissions: Array<Permissions> = [TRACKING_PERMISSION];
      const data: PermissionRequestResult = await atManager.requestPermissionsFromUser(ability.context, permissions);
      const authResults: Array<number> = data.authResults;
      return authResults.length > 0 && authResults[0] == 0;
    } catch (error) {
      const err = error as BusinessError;
      Log.e(TAG, `request APP_TRACKING_CONSENT failed: ${err.code} ${err.message}`);
      return false;
    }
  }
}
