 /* 
     Optical Leaf Area (OLA version 1.0.0)
  	
   -------------------------------------------
 
   A user-friendly code for optical leaf area measurement
   
   ImageJ Macro Language
   Author: Abbas Haghshenas
   abbas.haghshenas@shirazu.ac.ir; haqueshenas@yahoo.com
   Department of Plant Production and Genetics, Shiraz University, Iran
   April 2022
   License: MIT License
    
 
   Applications:
    
   -The present macro measures the conventional (optical) leaf area. The "Optical leaf area" term
   	has been introduced in contrast to the "Volumetric leaf area" concept, which was introduced
    in the preprint:
   		 Haghshenas, A., & Emam, Y. (2021). Accelerating leaf area measurement using a volumetric approach.
    	 bioRxiv, 2021.2007.2003.451015. https://doi.org/10.1101/2021.07.03.451015 
    Also, the manuscript has been submitted to Plant Methods.
    
   (It is notable that the present macro is a modified version of the VGA macro which is available at:
   	https://github.com/haqueshenas/Visual-Grain-Analyzer/tree/v.1.0.1)
   
   Acknowledgements:
    
   This macro has benefited from the valuable comments of experts on ImageJ Forum.
   The authors appreciate the help of below accounts:
   Biovoxxel (Jan Brocher), Brian Northan (bnorthan), Gabriel, Herbie, Jomaydc (Johanna), MicroscopyRA, NicoDF (Nicolás De Francesco),
   Thomas Peterbauer, and Wayne Rasband.
   We would also thank Anna Klemm (anna.klemm@it.uu.se) and NEUBIAS Academy for sharing a beneficial course on writing ImageJ/Fiji macro
   on YouTube.
   
   
   Copyright <2022> <Abbas Haghshenas & Yahya Emam, Department of Plant Production and Genetics, Shiraz University, Shiraz, Iran>
   
   Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files 
   (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge,
   publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
   subject to the following conditions:
   The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
   MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
   FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
   WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
   
   ---------------------------------------------------------------------------------------------------------------------------------------
  */
  
 // Setting measurements & options

	run("Set Measurements...", "area mean center perimeter shape "+
	"feret's integrated area_fraction stack limit display redirect=None decimal=9");
	
	setOption("BlackBackground", true);
	
 	// Choosing the input & output folders, and the size calibration sample:

	input_dir = getDirectory("Choose input folder");
	output_dir = getDirectory("Choose output folder");
	fileList = getFileList(input_dir); 

 	// "Setting" dialog window

	CalibrationMethod = newArray("Using calibration sample (camera)", "Using known resolution (scanner)");
	REFactor = 1;
	ThresholdingMethod = getList("threshold.methods");
	ThresholdingMethod = Array.concat(ThresholdingMethod, "Manual");
	SizeSieve = "0-Infinity";
	OutputDrawings = newArray("Outlines & labels", "Overlay, outlines, & labels", "Don't save drawings");
	LineWidth = 1;
	FontSize = 20;
	FontColor = newArray("Black", "Blue", "Cyan", "DarkGray", "Gray", "Green", "LightGray", "Magenta", "Orange",
						 "Pink", "Red", "White", "Yellow");
	WatershedType = newArray("Red (RGB)", "Green (RGB)", "Blue (RGB)", "Brightness (HSB)");
	Dialog.create("OLA settings");
	Dialog.addChoice("Imaging and calibration method:", CalibrationMethod);
	Dialog.addNumber("Resolution enhancement factor:", REFactor);
	Dialog.addChoice("Thresholding method:", ThresholdingMethod, "Huang");
	Dialog.addString("Size sieve (permissible area range; pixel^2):", SizeSieve);
	Dialog.addChoice("Output drawings:", OutputDrawings);
	Dialog.addNumber("Drawings line width (pixel):", LineWidth);
	Dialog.addNumber("Font size of labels:", FontSize);
	Dialog.addChoice("Font color (only for vectors):", FontColor, "Magenta");
	Dialog.addCheckbox("Dark background", false);
	Dialog.addCheckbox("Include the leaf holes", true);
	Dialog.show();
	CalibrationMethod = Dialog.getChoice();
	REFactor = Dialog.getNumber();
	ThresholdingMethod = Dialog.getChoice();
	SizeSieve = Dialog.getString();
	OutputDrawings = Dialog.getChoice();
	LineWidth = Dialog.getNumber();
	FontSize = Dialog.getNumber();
	FontColor = Dialog.getChoice();
	DarkBackground = Dialog.getCheckbox();
	IncludeHoles = Dialog.getCheckbox();

	
	if (IncludeHoles) {
		Include = " include";
	} else {
		Include = "";
	}

	if (DarkBackground == 1) {
		DarkBackgroundOption = "Yes";
	} else DarkBackgroundOption = "No";
	
	if (IncludeHoles == 1) {
		IncludeOption = "Yes";
	} else IncludeOption = "No";
				
	// Manual thresholding
	
	if (ThresholdingMethod == "Manual") {
	MinThresh = 0;
	MaxThresh = 0;
	Dialog.create("Manual thresholding");
	Dialog.addNumber("Lower threshold level:", MinThresh);
	Dialog.addNumber("Upper threshold level:", MaxThresh);
	Dialog.show();
	MinThresh = Math.round(Dialog.getNumber());
	MaxThresh = Math.round(Dialog.getNumber());
			
		if (MinThresh > MaxThresh) {
		showMessage("The lower level cannot be higher than the upper level!");
		Dialog.create("Manual thresholding");
		Dialog.addNumber("Lower threshold level:", MinThresh);
		Dialog.addNumber("Upper threshold level:", MaxThresh);
		Dialog.show();
		MinThresh = Math.round(Dialog.getNumber());
		MaxThresh = Math.round(Dialog.getNumber());
		}
			
		if (MinThresh > MaxThresh) {
			showMessage("The lower level cannot be higher than the upper level!");
			exit("VGA error: Incorrect thresholding!");
		}
			
		if (MinThresh < 0) {
		MinThresh = 0;
		}
		if (255 < MinThresh) {
		MinThresh = 255;
		}
		if (MaxThresh < 0) {
		MaxThresh = 0;
		}
		if (255 < MaxThresh) {
		MaxThresh = 255;
		}
	}
	
 // Imaging mode & size calibration
	
	// Camera mode

		if (CalibrationMethod == "Using calibration sample (camera)") {
	
		CalibDmm = getNumber("Please enter the diameter of circular calibration" + " sample (mm):", 20);
				
		open(File.openDialog("Choose image of calibration sample"));
		CalibTitle = getTitle();
		print("\nOptical Leaf Area (version 1.0.0)\n\n------------- Settings --------------" +
		"\n\nInput path: " + input_dir + "\nOutput path: " + output_dir + "\nCalibration method: " + CalibrationMethod + 
		"\nResolution enhancement factor: " + REFactor + "\nThresholding method: " + ThresholdingMethod);
			if (ThresholdingMethod == "Manual") {
		 		print("Manual thresholding levels: " + MinThresh + "-" + MaxThresh);
		 	}
		print("Size sieve (permissible area range; pixel^2): " + SizeSieve + "\nOutput drawings: " + OutputDrawings + "\nDark background: "
		+ DarkBackgroundOption + "\nLeaf holes were included: " + IncludeOption);

		print("Diameter of calibration sample (mm): " + CalibDmm + "\n\n------------- Calibration --------------\n\n"+
		"Processing the calibration sample...\n   please wait...");
	 	 
		run("Scale...", "x=&REFactor y=&REFactor interpolation=Bicubic create");
		rename(CalibTitle);
		run("Set Scale...", "known=1 unit=pixel");
		
		run("HSB Stack");
		run("Convert Stack to Images");
		selectWindow("Brightness");
		rename(CalibTitle);
		
		
		// Thresholding for calibration sample
		
		if (ThresholdingMethod == "Manual") {
			setThreshold(MinThresh, MaxThresh, "raw");
		} else {
																		
			if (DarkBackground) {
				setAutoThreshold("" + ThresholdingMethod + " dark");
			} else {
			 setAutoThreshold(ThresholdingMethod);
			}
		}
		
		// Analyzing the calibration sample
		
		run("Analyze Particles...", " size=0-Infinity clear include");
		close();
		if (nResults > 1) {
		exit("OLA error: More than one object was detected in the calibration image! Try other imaging or thresholding methods.");
		}
		if (nResults == 0) {
		exit("OLA error: No calibration sample was detected! Try other thresholding methods.");	
		}
		if (getResult("Circ.")<0.85) {
		exit("OLA error: The calibration sample seems not circular!");	
		}
	
		CalibDPix = getResult("Feret", nResults-1);
		CalibRatio = CalibDmm / CalibDPix;
		CalibRatio2 = Math.pow(CalibRatio,2);
	 
		print("\nSize calibration completed successfully!\n\n----------------------------------------");
		}

	// Scanner mode

		// Getting image resolution (for scanning mode):
		
	 	if (CalibrationMethod == "Using known resolution (scanner)") {
		GetResolution = newArray("Use image metadata", "I will enter it manually");
		Dialog.create("Resolution setting");
		Dialog.addChoice("Determining image resolution:", GetResolution);
		
		Dialog.show();
		GetResolution = Dialog.getChoice();
		GetRsolutionOption = "Using image Metadata";
	 	if (GetResolution == "I will enter it manually") {
			Resolution = getNumber("Please enter the scanning resolution (dpi):", 300)*REFactor;
			GetRsolutionOption = "Entered manually (" + Resolution/REFactor + " dpi)";
	  		}

		print("\nOptical Leaf Area (version 1.0.0)\n\n------------- Settings --------------" + 
		"\n\nInput path: "+ input_dir + "\nOutput path: " + output_dir + "\nCalibration method: " + CalibrationMethod + 
		"\nResolution enhancement factor: " + REFactor + "\nThresholding method: " + ThresholdingMethod);
			if (ThresholdingMethod == "Manual") {
		 		print("Manual thresholding levels: " + MinThresh + "-" + MaxThresh);
		 	}
		print("Size sieve (permissible area range; pixel^2): " + SizeSieve + "\nOutput drawings: " + OutputDrawings + "\nDark background: "
		+ DarkBackgroundOption + "\nHoles were included: "	+ IncludeOption);
		print("Resolution: " + GetRsolutionOption + "\n\n----------------------------------------");
	 	}

 // Batch processing
 
	setBatchMode(true);
	for (f=0; f<fileList.length; f++){
	process( input_dir, fileList[ f ], output_dir );		
	} 
	setBatchMode(false);
	function process( input_dir, file, output_dir )
	{
	
	// Clean-up to prepare for analysis
	
	roiManager("reset");	
	run("Close All");
	run("Clear Results");

	//Open file
	
	open(input_dir + file);
	print("Processing image: " + file + " ...\n   please wait...");
	
	title = getTitle();

    // Resolution enhancement of the input images
    
	run("Scale...", "x=&REFactor y=&REFactor interpolation=Bicubic create");
	rename(title);
	
	// Scanner mode
		// Setting resolution in "Use image metadata" mode
		
			if (CalibrationMethod == "Using known resolution (scanner)") {
				if (GetResolution == "Use image metadata") {
					getPixelSize(unit, pixelWidth, pixelHeight);
					if (pixelWidth != pixelHeight) {
					exit("OLA error: Pixel is not square! Use other calibration methods!");
					}
					if (unit != "inches") {
					exit("OLA error: No standard metadata was found! Enter the resolution "+
					"manually, or try other calibration methods.");
					}
					else {
					Resolution = 1/pixelWidth;
						 }
			    }
		   }

 	// Calibration for "scanner" mode
 
	if (CalibrationMethod == "Using known resolution (scanner)") {
	 run("Set Scale...", "distance=&Resolution known=1 unit=pixel");
     CalibRatio = 25.4/Resolution;
	 CalibRatio2 = Math.pow(CalibRatio,2);
	 }
	
	// Binarizing the input image
	
			
	 		run("HSB Stack");
	   		run("Convert Stack to Images");
	   		selectWindow("Brightness");
	   		rename(title);
	
	// Thresholding
		
			if (ThresholdingMethod == "Manual") {
				setThreshold(MinThresh, MaxThresh, "raw");
			} else {
		
				if (DarkBackground) {
			 		setAutoThreshold("" +ThresholdingMethod+ " dark");
				} else {
			  			setAutoThreshold(ThresholdingMethod);
						}
					}
	
	//Analyzing particles
	
		// Setting font size and line width of drawings
		
		   call("ij.plugin.filter.ParticleAnalyzer.setFontSize", FontSize);
		   call("ij.plugin.filter.ParticleAnalyzer.setLineWidth", LineWidth);
			
			// With a minor change, this part (i.e. the next 20 lines) is written and shared on ImageJ Forum by Wayne Rasband.
			// see: https://forum.image.sc/t/how-to-produce-custom-drawing-outputs-using-analyze-particle/63550		
	 if (OutputDrawings == "Overlay, outlines, & labels"){
		run("Set Scale...", "known=1 unit=pixel");
		run("Analyze Particles...", " size=&SizeSieve display show=Overlay clear" +Include+ "");
		resetThreshold;
		Overlay.drawLabels(false);
		n = Overlay.size;
		DFontSize = 10*REFactor;
		setFont("SansSerif", DFontSize, "antialiased");
		setColor(FontColor);
		for (i=0; i<n; i++) {
   		Overlay.activateSelection(i);
 	  		//Roi.setUnscalableStrokeWidth(2); // requires daily build
   		Overlay.addSelection("red");
   		Roi.getBounds(x, y, width, height);
   		x = x+width/2-round(DFontSize/2);
   		y = y+height/2+round(DFontSize/2);
   		Overlay.drawString(i+1, x, y)
   		run("Select None");
   		saveAs("Tiff", output_dir + title + "_processed.tif");
		}
	 }
	  else {
	
		ODindex = "Outlines";
	
	 if (OutputDrawings == "Outlines & labels"){ 
	     ODindex = "Outlines";} else 
	 if (OutputDrawings == "Fitted ellipses"){
		 ODindex = "Ellipses";} else 
								
	run("Set Scale...", "known=1 unit=pixel");
	run("Analyze Particles...", " size=&SizeSieve show=&ODindex display clear" +Include+ "");
	}
	
	// Results file
	
	if (nResults != 0){
	
	IJ.renameResults("Results");
	for (row=0; row<nResults; row++) {

		Circularity = getResult("Circ.", row);
		Solidity = getResult("Solidity", row);
		
			
	// Calculating the basic image-derived indices based on millimeter
	
		Perimmm = getResult("Perim.", row) * CalibRatio;
		setResult("Perim. (mm)", row, Perimmm);
		
		Feretmm = getResult("Feret", row) * CalibRatio;
		setResult("Feret (mm)", row, Feretmm);
		
		Areamm = getResult("Area", row) * CalibRatio2;
		setResult("Area (mm2)", row, Areamm);
		
		MinFmm = getResult("MinFeret", row) * CalibRatio;
		setResult("MinF (mm)", row, MinFmm);
	}


 //	Saving the results and outputs

	if (OutputDrawings != "Don't save drawings" && OutputDrawings != "Overlay, outlines, & labels") {
		saveAs("PNG", output_dir + title + "_processed.PNG");
	}
	
	saveAs("results", output_dir + title + ".csv");

	// Creating individual .csv files and "Total values.csv" table
	
	Num=nResults;

		if (nResults > 1){
			run("Summarize");
		}
		
		tableTitle = Table.title;
		Table.rename(tableTitle, "Results");
		headings = Table.headings;
		headingsArray = split(headings, "\t");

		if (isOpen("Total values")==false) {
			Table.create("Total values");
		}
	
		selectWindow("Total values");
		size = Table.size;

		
			if (nResults > 1) {
			data = Num * (getResultString(headingsArray[22], nResults-4));
			}
			else if (nResults < 2) {
			data = getResultString(headingsArray[22], nResults-1);
				 }

			selectWindow("Total values");
			Table.set("Label",size,title);
			Table.set(headingsArray[22], size, data);
			Table.update;
		}

	run("Close All");
	}
	
	saveAs("Results", output_dir + "Total values.csv");

 // Finalizing...
	print("\n----------------------------------------\n\nProcessing completed successfully!");
	selectWindow("Log");
	saveAs("Text", output_dir + "Log.txt");

	// Closing all open windows

		cleanUp();
		function cleanUp() {
    		requires("1.30e");
    		if (isOpen("Results")) {
        		selectWindow("Results"); 
        		run("Close" );
    		}
    
    		if (isOpen("Total values.csv")) {
        		selectWindow("Total values.csv");
        		run("Close" );
    		}     
    
    		wait(3000);   
        
    		if (isOpen("Log")) {
        		selectWindow("Log");
         		run("Close" );
    		}
    
    		while (nImages()>0) {
        		  selectImage(nImages());  
          	  	run("Close");
    		}
		}
    
 //	End.