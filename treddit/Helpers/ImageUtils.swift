//
//  ImageUtils.swift
//  treddit
//
//  Created by Anshu Dwibhashi on 29/3/21.
//

import UIKit
import MapKit

func saveImage(_ image: UIImage, toFile filename: String) {
    guard let data = image.jpegData(compressionQuality: 1) ?? image.pngData() else { return }
    guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) as NSURL else { return }
    
    try? data.write(to: directory.appendingPathComponent(filename)!)
}

func loadImage(fromFile filename: String) -> UIImage? {
    guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else { return nil }
    
    return UIImage(contentsOfFile: URL(fileURLWithPath: directory.absoluteString).appendingPathComponent(filename).path)
}

func drawCoordinatesOnMapSnapshot(_ coordinates: [CLLocationCoordinate2D],
                                  snapshot: MKMapSnapshotter.Snapshot) -> UIImage {
    let image = snapshot.image

    UIGraphicsBeginImageContextWithOptions(CGSize(width: 1600, height: 900), true, 0)

    image.draw(at: CGPoint.zero)
    
    let context = UIGraphicsGetCurrentContext()
    context!.setLineWidth(2.0)
    context!.setStrokeColor(UIColor.orange.cgColor)

    context!.move(to: snapshot.point(for: coordinates[0]))
    for i in 0...coordinates.count-1 {
      context!.addLine(to: snapshot.point(for: coordinates[i]))
      context!.move(to: snapshot.point(for: coordinates[i]))
    }
    
    context!.setStrokeColor(UIColor(red: 17.0/255.0, green: 147.0/255.0, blue: 255.0/255.0, alpha: 1).cgColor)
    context!.setLineWidth(15.0)
    context!.strokePath()
    let resultImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return resultImage!
}
