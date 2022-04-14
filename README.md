Optical Leaf Area (version 1.0.0)


(For more detailed information, please see the PDF version of README)

Optical Leaf Area (OLA) is a user-friendly ImageJ macro, which has utilized ImageJ/or Fiji facilities to provide a simple tool for leaf area measurement. 
This macro measures the conventional (optical) leaf area. The "Optical leaf area" term has been introduced in contrast to the "Volumetric leaf area" concept, which was introduced in the preprint:

Haghshenas, A., & Emam, Y. (2021). Accelerating leaf area measurement using a volumetric approach. bioRxiv, 2021.2007.2003.451015.
https://doi.org/10.1101/2021.07.03.451015

Also, the manuscript has been submitted to Plant Methods.

(It is notable that the present macro is a modified version of the VGA macro which is available at:
https://github.com/haqueshenas/Visual-Grain-Analyzer/tree/v.1.0.1 )

How to run?

For running this user-friendly macro, no scriptwriting or image processing skills are required. Just follow the below steps to process your own images, and extract the quantitative information:

1)	Download the free and open-source Fiji (or ImageJ) software from: https://imagej.net/software/fiji/downloads
2)	Create two input and output folders, and put your images in the input folder.
3)	Open the OLA.ijm macro in the Fiji. For this, you can either drag & drop the file into the Fiji head, or follow: File> Open.
4)	In the macro editor, click “Run” (if the Run button is hidden, you can follow Run> Run from the top bar). 
    Please wait for the message: “Processing completed successfully”.
5)	Follow the successive pop-up dialog windows of the macro, to initiate the processing. After clicking Ok in the last window, status of processing will be displayed on     the Log window. 
6)	Find the results in the output folder (you have determined the output path previously in the respective pop-up window).


Inputs

•	RGB images



Outputs

•	Single .csv files: include the quantitative results extracted from the individual images

•	“Total values .csv” file: provides the sum of the leaf area of each image (i.e. the total cumulative value of each individual .csv file).

•	Drawings: represent the visual output of image processing.

•	Log: general information about processing and settings are saved in this file.



Copyright

MIT license

Copyright <2022> <Abbas Haghshenas & Yahya Emam, Department of Plant Production and Genetics, Shiraz University, Shiraz, Iran>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
