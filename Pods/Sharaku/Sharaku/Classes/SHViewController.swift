//
//  SHViewController.swift
//  Pods
//
//  Created by 母利 睦人 on 2017/01/04.
//
//

import UIKit

public protocol SHViewControllerDelegate {
    func shViewControllerImageDidFilter(image: UIImage)
    func shViewControllerDidCancel()
}

public class SHViewController: UIViewController {
    public var delegate: SHViewControllerDelegate?
    fileprivate let filterNameList = [
        "Normal",
        "CIPhotoEffectChrome",
        "CIPhotoEffectFade",
        "CIPhotoEffectInstant",
        "CIPhotoEffectMono",
        "CIPhotoEffectNoir",
        "CIPhotoEffectProcess",
        "CIPhotoEffectTonal",
        "CIPhotoEffectTransfer",
        "CILinearToSRGBToneCurve",
        "CISRGBToneCurveToLinear"
    ]

    fileprivate let filterDisplayNameList = [
        "Normal",
        "Chrome",
        "Fade",
        "Instant",
        "Mono",
        "Noir",
        "Process",
        "Tonal",
        "Transfer",
        "Tone",
        "Linear"
    ]

    fileprivate var filterIndex = 0
    fileprivate let context = CIContext(options: nil)
    @IBOutlet var imageView: UIImageView?
    @IBOutlet var collectionView: UICollectionView?
    fileprivate var image: UIImage?
    fileprivate var smallImage: UIImage?

    public init(image: UIImage) {
        super.init(nibName: nil, bundle: nil)
        self.image = image
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func loadView() {
        if let view = UINib(nibName: "SHViewController", bundle: Bundle(for: self.classForCoder)).instantiate(withOwner: self, options: nil).first as? UIView {
            self.view = view
            if let image = self.image {
                imageView?.image = image
                smallImage = resizeImage(image: image)
            }
        }
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "SHCollectionViewCell", bundle: Bundle(for: self.classForCoder))
        collectionView?.register(nib, forCellWithReuseIdentifier: "cell")
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func imageViewDidSwipeLeft() {
        if filterIndex == filterNameList.count - 1 {
            filterIndex = 0
            imageView?.image = image
        } else {
            filterIndex += 1
        }
        if filterIndex != 0 {
            applyFilter()
        }
        updateCellFont()
        scrollCollectionViewToIndex(itemIndex: filterIndex)
    }

    @IBAction func imageViewDidSwipeRight() {
        if filterIndex == 0 {
            filterIndex = filterNameList.count - 1
        } else {
            filterIndex -= 1
        }
        if filterIndex != 0 {
            applyFilter()
        } else {
            imageView?.image = image
        }
        updateCellFont()
        scrollCollectionViewToIndex(itemIndex: filterIndex)
    }

    func applyFilter() {
        let filterName = filterNameList[filterIndex]
        if let image = self.image {
            if let fixOrientationImage = fixOrientationOfImage(image: image) {
                let filteredImage = createFilteredImage(filterName: filterName, image: fixOrientationImage)
                imageView?.image = filteredImage
            }
        }
    }

    func fixOrientationOfImage(image: UIImage) -> UIImage? {
        if image.imageOrientation == .up {
            return image
        }
        
        // We need to calculate the proper transformation to make the image upright.
        // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
        var transform = CGAffineTransform.identity
        
        switch image.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: image.size.width, y: image.size.height)
            transform = transform.rotated(by: CGFloat(Double.pi))
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: image.size.width, y: 0)
            transform = transform.rotated(by:  CGFloat(Double.pi / 2))
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: image.size.height)
            transform = transform.rotated(by:  -CGFloat(Double.pi / 2))
        default:
            break
        }
        
        switch image.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: image.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: image.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        default:
            break
        }
        
        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        guard let context = CGContext(data: nil, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: image.cgImage!.bitsPerComponent, bytesPerRow: 0, space: image.cgImage!.colorSpace!, bitmapInfo: image.cgImage!.bitmapInfo.rawValue) else {
            return nil
        }
        
        context.concatenate(transform)
        
        switch image.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            context.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width: image.size.height, height: image.size.width))
        default:
            context.draw(image.cgImage!, in: CGRect(origin: .zero, size: image.size))
        }
        
        // And now we just create a new UIImage from the drawing context
        guard let CGImage = context.makeImage() else {
            return nil
        }
        
        return UIImage(cgImage: CGImage)
    }

    func createFilteredImage(filterName: String, image: UIImage) -> UIImage? {
        // 1 - create source image
        let sourceImage = CIImage(image: image)

        // 2 - create filter using name
        let filter = CIFilter(name: filterName)
        filter?.setDefaults()

        // 3 - set source image
        filter?.setValue(sourceImage, forKey: kCIInputImageKey)

        // 4 - output filtered image as cgImage with dimension.
        let outputCGImage = context.createCGImage((filter?.outputImage!)!, from: (filter?.outputImage!.extent)!)

        // 5 - convert filtered CGImage to UIImage
        if outputCGImage != nil {
            return UIImage(cgImage: outputCGImage!)
        }
        else {
            
            return image
        }
//        let filteredImage = UIImage(cgImage: outputCGImage!)
    }

    func resizeImage(image: UIImage) -> UIImage {
        let ratio: CGFloat = 0.3
        let resizedSize = CGSize(width: Int(image.size.width * ratio), height: Int(image.size.height * ratio))
        UIGraphicsBeginImageContext(resizedSize)
        image.draw(in: CGRect(x: 0, y: 0, width: resizedSize.width, height: resizedSize.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage!
    }

    @IBAction func closeButtonTapped() {
        if let delegate = self.delegate {
            delegate.shViewControllerDidCancel()
        }
        dismiss(animated: true, completion: nil)
    }

    @IBAction func doneButtontapped() {
        if let delegate = self.delegate {
            delegate.shViewControllerImageDidFilter(image: (imageView?.image)!)
        }
        dismiss(animated: true, completion: nil)
    }
}

extension  SHViewController: UICollectionViewDataSource, UICollectionViewDelegate
{
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! SHCollectionViewCell
        var filteredImage = smallImage
        if indexPath.row != 0 {
            filteredImage = createFilteredImage(filterName: filterNameList[indexPath.row], image: smallImage!)
        }

        cell.imageView.image = filteredImage
        cell.filterNameLabel.text = filterDisplayNameList[indexPath.row]
        updateCellFont()
        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterNameList.count
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        filterIndex = indexPath.row
        if filterIndex != 0 {
            applyFilter()
        } else {
            imageView?.image = image
        }
        updateCellFont()
        scrollCollectionViewToIndex(itemIndex: indexPath.item)
    }

    func updateCellFont() {
        // update font of selected cell
        if let selectedCell = collectionView?.cellForItem(at: IndexPath(row: filterIndex, section: 0)) {
            let cell = selectedCell as! SHCollectionViewCell
            cell.filterNameLabel.font = UIFont.boldSystemFont(ofSize: 14)
        }

        for i in 0...filterNameList.count - 1 {
            if i != filterIndex {
                // update nonselected cell font
                if let unselectedCell = collectionView?.cellForItem(at: IndexPath(row: i, section: 0)) {
                    let cell = unselectedCell as! SHCollectionViewCell
                    if #available(iOS 8.2, *) {
                        cell.filterNameLabel.font = UIFont.systemFont(ofSize: 14.0, weight: UIFont.Weight.thin)
                    } else {
                        // Fallback on earlier versions
                        cell.filterNameLabel.font = UIFont.systemFont(ofSize: 14.0)
                    }
                }
            }
        }
    }

    func scrollCollectionViewToIndex(itemIndex: Int) {
        let indexPath = IndexPath(item: itemIndex, section: 0)
        self.collectionView?.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
}
