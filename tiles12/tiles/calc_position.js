import fs from 'fs';
import turf from '@turf/turf';


const zipFilename = process.argv[2];

if (!zipFilename) {
	console.error("No zip filename provided");
	process.exit(1);
}

// Load the mesh index data
const meshData = JSON.parse(fs.readFileSync('mesh-index-2023.json', 'utf8'));

// Find the entry corresponding to the provided zip filename
const meshEntry = meshData.find(entry => entry.zip === zipFilename);

if (!meshEntry || !meshEntry.coordinates) {
	console.error("No matching entry found or coordinates missing in the mesh index for the provided filename");
	process.exit(1);
}

// Function to calculate the center of coordinates
function getCenter(coords) {
    const polygon = turf.polygon([coords]);
    const centroid = turf.centroid(polygon);
    return [centroid.geometry.coordinates[1], centroid.geometry.coordinates[0]];  // Return as lat, lon
}


// Extract coordinates from the mesh data and calculate the centroid
const coords = meshData['coordinates'];
if (!coords) {
    console.error("No coordinates found in the mesh data");
    process.exit(1);
}

const center = getCenter(coords);

console.log(center.join(' '));
