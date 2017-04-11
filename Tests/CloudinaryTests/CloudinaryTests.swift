import XCTest
@testable import Cloudinary

class CloudinaryTests: XCTestCase {
    func testExample() {
      let cloud = Cloudinary(cloud_name: "dh0t9fojh", user_name: "enochwills", api_key: "188382239119756", api_secret: "yUm_U5o4hI5Es1mvqcm1uGUHupQ")
      do {
        let r = try cloud.upload(fileName: "/tmp/qr.png")
        print(r)
      }catch(let err) {
        XCTFail(err.localizedDescription)
      }
    }


    static var allTests = [
        ("testExample", testExample),
    ]
}
