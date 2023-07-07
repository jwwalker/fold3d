#!/bin/sh

#  Notarize.sh
#  Fold3D
#
#  Created by James Walker on 7/7/23.
#  

cd "$CONFIGURATION_BUILD_DIR"

/usr/bin/ditto -c -k --sequesterRsrc --keepParent VRML+3DMF.bblm Fold3D.zip

/usr/bin/xcrun notarytool submit Fold3D.zip --apple-id "jw@jwwalker.com" --team-id FDHC2KMZ6V --keychain "~/Library/Keychains/jwwalker.keychain" --keychain-profile "personal-notarize" --wait

/usr/bin/xcrun stapler staple VRML+3DMF.bblm
