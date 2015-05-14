/**
 * Getting Started with Capture.
 * 
 * Reading and displaying an image from an attached Capture device. 
 */

import http.requests.*;
import rekognition.faces.*;

import processing.video.*;
Capture cam;

String api = "http://rekognition.com/func/api/";

int value = 0;
PImage img;
Rekognition rekog;
RFace[] faces;
final String filename = "portraet.jpg";
String api_key;
String api_secret;

void setup() {
  size(displayWidth, displayHeight);

  String[] cameras = Capture.list();

  if (cameras == null) {
    println("Failed to retrieve the list of available cameras, will try the default...");
    //cam = new Capture(this, 640, 480);
  }
  
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println(cameras[i]);
    }

    // The camera can be initialized directly using an element
    // from the array returned by list():
    cam = new Capture(this, cameras[0]);
    // Or, the settings can be defined based on the text in the list
    //cam = new Capture(this, 640, 480, "Built-in iSight", 30);
    
    // Start capturing the images from the camera
    cam.start();
    
 // load image for drawing
  
  img = loadImage(filename);

  // Load the API keys
  String[] keys = loadStrings("key.txt");
  api_key = keys[0];
  api_secret = keys[1];

  // Create the face recognizer object
  rekog = new Rekognition(this, api_key, api_secret);

  // Recognize faces in image
  //faces = rekog.recognize(filename);
  faces = recognizeFacesPathHack(filename);
  }
}

void draw() {
   
  
  if (cam.available() == true) {
    cam.read();
  }
  image(cam, 0, 0, displayWidth/2, displayHeight/2);
  // The following does the same as the above image() line, but 
  // is faster when just drawing the image without any additional 
  // resizing, transformations, or tint.
  //set(0, 0, cam);
  
  // Displays the image at its actual size at point (0,0)
 // image(img, 0, 0);
  // Displays the image at point (0, height/2) at half of its size
  //image(img, 0, height, img.width, img.height);
 // image(img, 0, height, img.width, img.height);
 
 

  // The face objects have lots of information stored
  for (int i = 0; i < faces.length; i++) {
    noStroke();
    strokeWeight(1);
    noFill();
    rectMode(CENTER);

    // Face center, with, and height
    // We could also get eye, mouth, and nose positions like in FaceDetect
    rect(faces[i].center.x, faces[i].center.y, faces[i].w, faces[i].h);  

    // Possible face matches come back in a FloatDict
    // A string (name of face) is paired with a float from 0 to 1 (how likely is it that face)
    FloatDict matches = faces[i].getMatches();
    textSize(25);
    fill(255);
    String display = "";
    for (String key : matches.keys()) {
      float likely = matches.get(key);
      display += key + ": " + likely + "\n";
    }
    
    //println(faces[i].getMatches());

    
    // We could also get Age, Gender, Smiling, Glasses, and Eyes Closed data like in the FaceDetect example
    fill(255);
    rect(width-width/4, height/2, height, width);
    fill(0);
    text(display, width-width/3, height/3);

  }
}

RFace[] facesFromJSONHack(String content) {
    JSONObject data = parseJSONObject(content);
    JSONArray facearray = data.getJSONArray("face_detection");
    println(data);
    RFace[] faces = new RFace[facearray.size()];
    for (int i = 0; i < faces.length; i++) {
      faces[i] = new RFace();  // Fix to include width and height!
      faces[i].fromJSON(facearray.getJSONObject(i));
    }
    return faces;
  }

RFace[]  recognizeFacesPathHack(String path) {
    PostRequest post = new PostRequest(api);
    post.addData("api_key", api_key);
    post.addData("api_secret", api_secret);

    post.addData("name_space","default");
    post.addData("user_id","default");

    post.addData("job_list", "face_celebrity_part_gender_emotion_age_glass");
    File f = new File(sketchPath(path));

    // Now try data paths
    if (!f.exists()) {
      f = new File(dataPath(path));
    }
    post.addFile("uploaded_file", f);
    post.send();
    String content = post.getContent();

    return facesFromJSONHack(content);
}  
  void mousePressed(){
  if (value == 0) {
    value = 255;
  } else {
    value = 0;
  }


 // PImage newImage = createImage(640, 480, RGB);
 // newImage.save("Lili.jpg");
  
// Saves a JPG file 
save(filename);
img = loadImage(filename);
image(img, 0, 400);

  faces = recognizeFacesPathHack(filename);

}

