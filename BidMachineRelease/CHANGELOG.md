# Version 1.7.3.1 (May 14th, 2021)

- Added API for transfer external user ids
- Fix thread unsafe call
- Fix video payload validation

# Version 1.7.3.0 (Apr 20th, 2021)

- Append SkAdNetwork 2.2 support
- Append OM MRAID/VAST support
- Small fixes

# Version 1.7.2.0 (Apr 12th, 2021)

- Append bid payload

# Version 1.7.1.0 (Mar 30th, 2021)

- SDK improvement
- Update header bidding configuration method
- Adapters are put in a separate project
- Deprecated client-side rounding, use server side rounding
- Deprecated BDMFetcher user BDMRequestStorage to save request

# Version 1.6.5 (Mar 19th, 2021)

- Update Fullscreen ads viewability logic
	Now the viewability interval is set on the server (1 sec - default)
- Update Banner ads click callback logic 

# Version 1.6.4 (Dec 18th, 2020)

- Append support IAB TCF 2.0
- Fixed a potential type incompatibility crash

# Version 1.6.3 (Nov 11th, 2020)

- Criteo 3.4.1 - 4.0.1

# Version 1.6.2 (Oct 26th, 2020)

- Fix NativeAds (update asset ID)
- Small fixes

# Version 1.6.1 (Oct 19th, 2020)

- Update FBAudienceNetwork 6.0.0
- Small fixes

# Version 1.6.0 (Sep 22th, 2020)

- Vungle 6.5.2 - 6.7.1
- Adcolony 4.1.4 - 4.3.1
- TapjoySDK 12.4.2 - 12.6.1
- MyTarget 5.4.2 - 5.8.0
- Smaato-ios-sdk 21.2.2 - 21.6.1
- Append request HB support
- Remove MintegralAdSDK adapter
- Deprecated BDMRequest.targeting
- Added additional targeting fields
- BDMSdk.restrictions now readonly property
- SDK improvements

# Version 1.5.3 (Sep 4th, 2020)
- Small fixes on thread safety

# Version 1.5.2 (Aug 3th, 2020)

- Append Criteo rotation unit logic
- Update FBAudienceNetwork 5.10.1

# Version 1.5.1 (July 28th, 2020)

- append fetcher

# Version 1.5.0 (July 10th, 2020)

- SDK improvement
- Append request extras method
- Append request custom params
- Small fixes

# Version 1.4.3 (Mar 18th, 2020)

- Vungle 6.4.6 - 6.5.2
- Adcolony 4.1.2 - 4.1.4
- TapjoySDK 12.3.4 - 12.4.2
- FBAudienceNetwork 5.6.0 - 5.7.1
- MintegralAdSDK 5.8.4.0 - 6.0.0.0
- Append CCPA support
- Append Criteo adapter 3.4.1
- Bugfix: Append Interstitial Reward callback

# Version 1.4.2 (Feb 23th, 2020)

- VAST postbanner default close time fix
- VAST postbanner Ipad orientation fix
- VAST postbanne static image style append
- MRAID offscreen loading append

# Version 1.4.1 (Jan 21th, 2020)

- VAST/MRAID Small fixes
- Add Public Publisher Api
- Add Api for disable HB

# Version 1.4.0 (Nov 29th, 2019)

- Add Native Ad support

# Version 1.3.0 (Aug 13th, 2019)

- Add Header Bidding AdColony adapter
- Add Header Bidding Tapjoy adapter
- Add Header Bidding FacebookAudienceNetwork adapter
- Add Header Bidding MyTarget adapter
- Add Header Bidding Vungle adapter
- Add ability to change base URL
- Extend event tracking

# Version 1.1.1 (Jun 19th, 2019)

- Minor fixes in MRAID viewability tracking logic

# Version 1.1.0 - (Jun 6th, 2019)

- Extend event tracking 
- Migrate to MobileDisplayManagers module for creative rendering

# Version 1.0.3 - (May 10th, 2019)

- Add additional banner callbacks for MoPub mediation supports

# Version 1.0.2 - (May 2d, 2019)

- Miscellaneous technical improvements

# Version 1.0.1 - (Apr 26th, 2019)

- Miscellaneous technical improvements

# Version 1.0.0 - (Apr 20th, 2019)

- Add supports of banner, interstitial and rewarded ad types
- Add supports of MRAID, VAST ad formats
