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
    case PROCESS_FAULT(String)
  }

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

    let flags = [
      "-v", "-X", "POST",
      "-F", "timestamp=\(timestamp)",
      "-F", "api_key=\(api_key)",
      "-F", "signature=\(signature)",
      "-F", "tags=\(user_name)",
      "-F", "file=@\(fileName)",
      "https://api.cloudinary.com/v1_1/\(cloud_name)/\(resource_type)/upload"
    ]//end flags

    // although curl has a very powerful form of https://curl.haxx.se/libcurl/c/curl_formadd.html
    // curl_formadd() function is not supported by Swift language due to the inifinte parameters are fully banned
    // then it is not possible to implement it in PerfectCURL unless adding more C sources
    // so before any further better solutions, we have to use the system shell instead
    let proc = try SysProcess("curl", args: flags, env: [("PATH", "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin")])
    let ret = try proc.wait(hang: true)
    guard ret == 0, let stdout = try proc.stdout?.readString() else {
      throw Exception.PROCESS_FAULT(try proc.stderr?.readString() ?? "Fault Without Reasons")
    }//end if

    return try stdout.jsonDecode() as? [String:Any] ?? [:]
  }//end upload
}//end Cloudinary
