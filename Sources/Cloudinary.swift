import cURL
import PerfectCURL
import PerfectCrypto
import PerfectLib

#if os(Linux)
  import SwiftGlibc
#else
  import Darwin
#endif

/// Experimental Cloudinary Class
public class Cloudinary {

  /// account name
  internal var cloud_name = ""

  /// user name
  internal var user_name = ""

  /// api key for the account
  internal var api_key = ""

  /// api secret for the account
  internal var api_secret = ""

  /// errors
  public enum Exception: Error {

    /// when sha-1 fault
    case INVALID_DIGEST

    /// when CURL fault
    case INVALID_URL(String)
  }//end 

  public var DEBUG = false

  /// constructor
  /// - parameters:
  ///   - cloud_name: account name
  ///   - user_name: user's name
  ///   - api_key: api key of the account
  ///   - api_secret: api secret of the account
  public init(cloud_name: String, user_name: String, api_key: String, api_secret: String) {
    self.cloud_name = cloud_name
    self.user_name = user_name
    self.api_key = api_key
    self.api_secret = api_secret
  }//end init

  /// upload an image
  /// - parameters:
  ///   - fileName: local file name, /path/to
  ///   - resource_type: default is "image"
  /// - throws:
  ///   Exceptions
  /// - returns:
  ///   decoded json as an dictionary
  public func upload (fileName: String, resource_type: String = "image") throws -> [String:Any] {

    let timestamp = time(nil)

    let value = "tags=\(user_name)&timestamp=\(timestamp)\(api_secret)"

    guard let sha1 = value.digest(.sha1)?.encode(.hex),
      let signature = String(validatingUTF8:sha1) else {
        throw Exception.INVALID_DIGEST
    }//end guard

    let fields = CURL.POSTFields()
    let _ = fields.append(key: "timestamp", value: "\(timestamp)")
    let _ = fields.append(key: "api_key", value: api_key)
    let _ = fields.append(key: "signature", value: signature)
    let _ = fields.append(key: "tags", value: user_name)
    let _ = fields.append(key: "file", path: fileName)

    let curl = CURL(url: "https://api.cloudinary.com/v1_1/\(cloud_name)/\(resource_type)/upload")
    let ret = curl.formAddPost(fields: fields)
    defer { curl.close() }
    guard ret.rawValue == 0 else {
      throw Exception.INVALID_URL(curl.strError(code: ret))
    }//end guard
    let _ = curl.setOption(CURLOPT_VERBOSE, int: self.DEBUG ? 1 : 0 )
    let r = curl.performFullySync()
    var ptr = r.bodyBytes
    ptr.append(0)
    let s = String(cString: ptr)
    guard r.resultCode == 0, r.responseCode == 200 else {
      throw Exception.INVALID_URL(s)
    }//end guard
    return try s.jsonDecode() as? [String:Any] ?? [:]
  }//end upload
}//end Cloudinary
