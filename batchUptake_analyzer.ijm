/*
 * This is a generalized script to batch analyze the uptake
 * of fluorescent nanoparticles taken up by cells. The data
 * needs to be a sequence of images with multiple channels 
 * (one for the particles and one for the cells).
 * 
 * Written by:  Thomas L. Moore
 *
 * Contact: tlmoore1928@gmail.com
 *
 * This macro is in the public domain. Feel free to use and
 * modify it.
 */

// Choose the directory to analyze
dir = getDirectory("Choose a Directory to PROCESS");
file_list = getFileList(dir);
open(proc_dir+list[0]); // Open the first file in the working directory 

title = getTitle(); // get window title
dotIndex = indexOf(title, "."); // set dot index for image title
img_title = substring(title, 0, dotIndex);

// Set parameters on the first image
run("Z Project...", "projection=[Max Intensity]");
selectWindow(title);
close();
selectWindow("MAX_"+title);
run("Channels Tool...");

// Create a dialog window to get user inputs
Dialog.create("User Inputs")
Dialog.addMessage("Please input necessary values.");
Dialog.addNumber("Particle channel number:", 1);
Dialog.addNumber("Cell channel number:", 2);
Dialog.show();

np_chNum = Dialog.getNumber();
cell_chNum = Dialog.getNumber();



// Create function for processing images
function particle_area(input, output, filename){
	// Load the image file
	open(input+filename);
	title = getTitle(); // get window title
	dotIndex = indexOf(title, "."); // set dot index for image title
	img_title = substring(title, 0, dotIndex); // subset only image title (remove file type)
	winName_np_ch = "C"+np_chNum+"-MAX_"+title
	winName_cell_ch = "C"+cell_chNum+"-MAX_"+title
	// Perform maximum intensity projection on image
	run("Z Project...", "projection=[Max Intensity]");
	selectWindow(title);
	close();
	selectWindow("MAX_"+title);
	run("Channels Tool...");
	run("Color Balance...");
	waitForUser("User Input", "Use the Color Balance tool to adjust each channel.");
	// Split the image into separate channels
	run("Split Channels");
	selectWindow(winName_cell_ch); // select cell channel
	run("Threshold...");
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Fill Holes");

	// Save the image/results files
	saveAs("Results", results_dir+img_title+".csv");
	saveAs("Drawing of "+title, results_dir+"outlines_"+title);
	selectWindow(title);
	close();
	selectWindow("outlines_"+title);
	close();
	selectWindow("Results");
	close();
}

//setBatchMode(true)
for (i=0; i < list.length; i++){
	particle_area(dir, results_dir, file_list[i]);
}
//setBatchMode(false);