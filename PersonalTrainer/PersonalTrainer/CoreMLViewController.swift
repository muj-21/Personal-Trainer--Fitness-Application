//
//  CoreMLViewController.swift
//  PersonalTrainer
//
//  Created by Mujtaba Ahmed on 26/02/2018.
//  Copyright © 2018 Mujtaba Ahmed. All rights reserved.
//

import UIKit

class CoreMLViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    //Create variable which references the VGG16 Core ML model
    var vgg: VGG16?
    
    //Connect outlets
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var classLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vgg = VGG16()
        // Do any additional setup after loading the view.
    }
    
    
    //The image classified is displayed to the top

    func classify(image: UIImage) {
        let buffer = pixelBufferFromImage(image: image)
        do {
            let answer = try vgg?.prediction(image: buffer)
//            classLabel.text = "This is a \(try vgg?.prediction(image: buffer))"
            
            let present = answer?.classLabel
            classLabel.text = "This is a \(String(describing: present!))"

        } catch {
            // handle error
        }
    }
    //Prompt is popped up asking the user to select an image from Library, Take a picture and cancel
    @IBAction func addNewPicture(_ sender: UIBarButtonItem) {
        
        let actionSheet = UIAlertController(title:nil, message:nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title:"Take a picture", style: .default) {
            (_) in self.takePicture()
        }
        let libraryAction = UIAlertAction(title: "Choose from library", style: .default){
            (_)in self.choosePicture()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(cameraAction)
        actionSheet.addAction(libraryAction)
        actionSheet.addAction(cancelAction)
        present(actionSheet, animated: true, completion: nil)
    }
    func choosePicture() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    func takePicture(){
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: true, completion: nil)
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            pictureImageView.image = image
            classify(image: image)
        }
    }
    //Need to resize the image to the correct VGG16 input format
    func resize(image: UIImage, newSize:CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    
    //Need to create a CVPixelBuffer from the image data becuase the VGG16 model expects that as an argument
    
    func pixelBufferFromImage(image: UIImage) -> CVPixelBuffer{
        
        
        //The input image for VGG16 should be 224x244 so would need to resize the image selectd
        let newImage = resize(image: image, newSize: CGSize(width: 224/3.0, height: 224/3.0))
        
        
        //Formatting the Image to CV Pixel Buffer
        
        let ciimage = CIImage(image: newImage!)
        let tmpcontext = CIContext(options: nil)
        let cgimage = tmpcontext.createCGImage(ciimage!, from: ciimage!.extent)
            
        let cfnumPointer = UnsafeMutablePointer<UnsafeRawPointer>.allocate(capacity: 1)
        let cfnum = CFNumberCreate(kCFAllocatorDefault, .intType, cfnumPointer)
        let keys: [CFString] = [kCVPixelBufferCGImageCompatibilityKey, kCVPixelBufferCGBitmapContextCompatibilityKey, kCVPixelBufferBytesPerRowAlignmentKey]
        let values: [CFTypeRef] = [kCFBooleanTrue, kCFBooleanTrue, cfnum!]
        let keysPointer = UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: 1)
        let valuesPointer =  UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: 1)
        keysPointer.initialize(to: keys)
        valuesPointer.initialize(to: values)
            
        let options = CFDictionaryCreate(kCFAllocatorDefault, keysPointer, valuesPointer, keys.count, nil, nil)
            
        let width = cgimage!.width
        let height = cgimage!.height
            
        var pxbuffer: CVPixelBuffer?
        var status = CVPixelBufferCreate(kCFAllocatorDefault, width, height,
                                             kCVPixelFormatType_32BGRA, options, &pxbuffer)
        status = CVPixelBufferLockBaseAddress(pxbuffer!, CVPixelBufferLockFlags(rawValue: 0))
            
        let bufferAddress = CVPixelBufferGetBaseAddress(pxbuffer!)
            
            
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesperrow = CVPixelBufferGetBytesPerRow(pxbuffer!)
        let context = CGContext(data: bufferAddress,
                                width: width,
                                height: height,
                                bitsPerComponent: 8,
                                bytesPerRow: bytesperrow,
                                space: rgbColorSpace,
                                bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)
        context?.concatenate(CGAffineTransform(rotationAngle: 0))
        context?.concatenate(__CGAffineTransformMake( 1, 0, 0, -1, 0, CGFloat(height) ))
            
        context?.draw(cgimage!, in: CGRect(x:0, y:0, width:CGFloat(width), height:CGFloat(height)))
        status = CVPixelBufferUnlockBaseAddress(pxbuffer!, CVPixelBufferLockFlags(rawValue: 0))
        return pxbuffer!
            
    }

}
