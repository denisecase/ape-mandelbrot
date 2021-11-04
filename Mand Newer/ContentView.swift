//
//  ContentView.swift
//  Mand Newer
//
//  Created by Bruce Johnson on 9/20/21.
//

import SwiftUI

struct ContentView: View {

    var body: some View {

            let imageWidth: Int = 1000
            let imageHeight: Int = 1000
            let iMax: Float = 10_000.0
            var rSq: CGFloat = 0.0
            var rSqLimit: CGFloat = 0.0
            var rSqMax: CGFloat = 0.0
            var x0: CGFloat = 0.0
            var y0: CGFloat = 0.0
            var xC: CGFloat = 0.0
            var yC: CGFloat = 0.0
            var xx: CGFloat = 0.0
            var yy: CGFloat = 0.0
            var xTemp: CGFloat = 0.0
            var iter: Float = 0.0
            var dIter: Float = 0.0
            var gGML: CGFloat = 0.0
            var gGL: CGFloat = 0.0
            var fIter = [[Float]](repeating: [Float](repeating: 0.0, count: imageHeight), count: imageWidth)
            var fIterMinLeft: Float = 0.0
            var fIterMinRight: Float = 0.0
            var fIterBottom = [Float](repeating: 0.0, count: imageWidth)
            var fIterTop = [Float](repeating: 0.0, count: imageWidth)
            var fIterMinBottom: Float = 0.0
            var fIterMinTop: Float = 0.0
            var fIterMins = [Float](repeating: 0.0, count: 4)
            var fIterMin: Float = 0.0
            var scale: CGFloat = 0.0
            var p: CGFloat = 0.0
            var test1: CGFloat = 0.0
            var test2: CGFloat = 0.0
            
            rSqLimit = 400.0
     
            xC = -0.148238
            yC = 0.651878
            scale = 33_320_000
            
            rSqMax = 162_000.0
            gGML = log( log(rSqMax) ) - log(log(rSqLimit) )
            gGL = log(log(rSqLimit) )

            for u in 0...imageWidth - 1 {
            
                for v in 0...imageHeight - 1 {

                x0 = xC + (CGFloat(u) - CGFloat(imageWidth/2))/scale
                y0 = yC + (CGFloat(v) - CGFloat(imageHeight/2))/scale
                xx = x0
                yy = y0
                rSq = xx*xx + yy*yy
                iter = 0.0
                
                p = sqrt((xx - 0.25)*(xx - 0.25) + yy*yy)
                test1 = p - 2.0*p*p + 0.25
                test2 = (xx + 1.0)*(xx + 1.0) + yy*yy
                
                if xx < test1 || test2 < 0.0625 {
                    fIter[u][v] = iMax  // black
                    iter = iMax  // black
                    }   //end if
                
                else {
                    for i in 1...Int(iMax) {
                        if rSq >= rSqLimit{
                            break
                        }
                        
                        xTemp = xx*xx - yy*yy + x0
                        yy = 2*xx*yy + y0
                        xx = xTemp
                        rSq = xx*xx + yy*yy
                        iter = Float(i)
                            }
                    }   //end else
                
                if iter < iMax {
                    
                    dIter = Float(-(  log( log(rSq) ) - gGL  )/gGML)
      
                    fIter[u][v] = iter + dIter
                    }   //end if
                
                else {
                    fIter[u][v] = iter
                    }   //end else
                
                }    // end first for v
            
            }    // end first for u
                
            for u in 0...imageWidth - 1 {
                
                fIterBottom[u] = fIter[u][0]
                fIterTop[u] = fIter[u][imageHeight - 1]
                
                }    // end second for u

            fIterMinLeft = fIter[0].min()!
            fIterMinRight = fIter[imageWidth - 1].min()!
            fIterMinBottom = fIterBottom.min()!
            fIterMinTop = fIterTop.min()!
            fIterMins = [fIterMinLeft, fIterMinRight, fIterMinBottom, fIterMinTop]
            fIterMin = fIterMins.min()!
            
            // Now we need to generate a bitmap image.
            
            var contextImage: CGImage
            var nBlocks: Int = 0
            var nColors: Int = 0
            var color: Float = 0.0
            var b0: Int = 0
            var b1: Int = 0
            var block1: Float = 0.0
                
            nBlocks = 60
                            
            block1 = 1.0
            
            var blockBound = [Float](repeating: 0.0, count: nBlocks + 1)
             
             let colors: [[Float]] = [[0.0, 255.0, 0.0], [255.0, 255.0, 0.0], [255.0, 0.0, 0.0], [255.0, 0.0, 255.0], [0.0, 0.0, 255.0], [0.0, 255.0, 255.0]]
            
            nColors = colors.count
            
            var h: Float = 0.0
            var xX: Float = 0.0
            var k: Float = 0.0
   
            var B: Float = 0.0
            
            B = (log10((iMax + 1.0)/block1))/Float((nBlocks - 1))
            k = pow(10.0, B)
                
                for i in 1...nBlocks {
                    blockBound[i] = block1*pow(k, Float(i - 1))
                }

            // set up CG parameters
            let bitsPerComponent: Int = 8   // for UInt8
            let componentsPerPixel: Int = 4  // RGBA = 4 components
            let bytesPerPixel: Int = (bitsPerComponent * componentsPerPixel) / 8 // 32/8 = 4
            let bytesPerRow: Int = imageWidth * bytesPerPixel
            let rasterBufferSize: Int = imageWidth * imageHeight * bytesPerPixel
            
            // Allocate data for the raster buffer.  I'm using UInt8 so that I can
            // address individual RGBA components easily.
            let rasterBufferPtr: UnsafeMutablePointer<UInt8> = UnsafeMutablePointer<UInt8>.allocate(capacity: rasterBufferSize)
            
            // Create a CGBitmapContext for drawing and converting into an image for display
            let context: CGContext = CGContext(data: rasterBufferPtr,
               width: imageWidth,
               height: imageHeight,
               bitsPerComponent: bitsPerComponent,
               bytesPerRow: bytesPerRow,
               space: CGColorSpace(name:CGColorSpace.sRGB)!,
               bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
            
            // use CG to draw into the context
            // you can use any of the CG drawing routines for drawing into this context
            // here we will just erase the contents of the CGBitmapContext as the
            // raster buffer just contains random uninitialized data at this point.
            context.setFillColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)   // white
            context.addRect(CGRect(x: 0.0, y: 0.0, width: CGFloat(imageWidth), height: CGFloat(imageHeight)))
            context.fillPath()
            
            // in addition to using any of the CG drawing routines, you can draw yourself
            // by accessing individual pixels in the raster image.
            // here we'll draw a square one pixel at a time.
            let xS: Int = 0
            let yS: Int = 0
            let width: Int = imageWidth
            let height: Int = imageHeight

            // iterate over all of the rows for the entire height of the square
            for v in 0...(height - 1) {
            
            // calculate the offset to the row of pixels in the raster buffer
            // assume the origin is at the bottom left corner of the raster image.
            // note, you could also use the top left, but GC uses the bottom left
            // so this method keeps your drawing and CG in sync in case you wanted
            // to use the CG methods for drawing too.
            //
            // note, you could do this calculation all together inside of the xoffset
            // loop, but it's a small optimization to pull this part out and do it here
            // instead of every time through.
                let pixel_vertical_offset: Int = rasterBufferSize - (bytesPerRow*(Int(yS)+v+1))
            
            // iterate over all of the pixels in this row
            for u in 0...(width - 1) {
            
            // calculate the horizontal offset to the pixel in the row
                let pixel_horizontal_offset: Int = ((Int(xS) + u) * bytesPerPixel)
            
            // sum the horixontal and vertical offsets to get the pixel offset
            let pixel_offset = pixel_vertical_offset + pixel_horizontal_offset
            
            // calculate the offset of the pixel
            let pixelAddress:UnsafeMutablePointer<UInt8> = rasterBufferPtr + pixel_offset
                
                if fIter[u][v] >= iMax  {               //black
                pixelAddress.pointee = UInt8(0)         //red
                (pixelAddress + 1).pointee = UInt8(0)   //green
                (pixelAddress + 2).pointee = UInt8(0)   //blue
                (pixelAddress + 3).pointee = UInt8(255) //alpha
                
                }   //end if

                else    {
                h = fIter[u][v] - fIterMin
                
                for b in 0...nBlocks {
                
                    b0 = b
                    
                    if h >= blockBound[b] && h < blockBound[b + 1]   {
                    
                    xX = (h - blockBound[b])/(blockBound[b + 1] - blockBound[b])
                
                    while b0 > nColors - 1 {
                        b0 = b0 - nColors
                    }
                    
                    b1 = b0 + 1
                    
                    if b1 == nColors {
                        b1 = b1 - nColors
                    }
                    
                    color = colors[b0][0] + xX*(colors[b1][0] - colors[b0][0])
                    pixelAddress.pointee = UInt8(color)         // R
                   
                    color = colors[b0][1] + xX*(colors[b1][1] - colors[b0][1])
                    (pixelAddress + 1).pointee = UInt8(color)   // G
                    
                    color = colors[b0][2] + xX*(colors[b1][2] - colors[b0][2])
                    (pixelAddress + 2).pointee = UInt8(color)   // B
                    
                    (pixelAddress + 3).pointee = UInt8(255)     //alpha
                    
                    }
                
                }
            
            // IMPORTANT:
            // there is no type checking here and it is up to you to make sure that the
            // address indexes do not go beyond the memory allocated for the buffer
            }    //end else
            
            }    //end for u
                
            }    //end for v
            
            // convert the context into an image
            contextImage = context.makeImage()!
            
            // no automatic deallocation for the raster data
            // you need to manage that yourself
            rasterBufferPtr.deallocate()
                
        return Image(contextImage, scale: 1.0, label: Text("Test"))
                
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}