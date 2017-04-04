import XCTest
@testable import Cloudinary

class CloudinaryTests: XCTestCase {
    func testExample() {
      let cloud = Cloudinary(cloud_name: "your_account_name", user_name: "your_user_name", api_key: "your_api_key", api_secret: "your_api_secret")
      do {
        let r = try cloud.upload(fileName: "/path/to/some.jpg")
        print(r)
      }catch(let err) {
        XCTFail(err.localizedDescription)
      }
    }


    static var allTests = [
        ("testExample", testExample),
    ]
}
