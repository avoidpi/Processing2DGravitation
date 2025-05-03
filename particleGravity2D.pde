//options (do touch this if you want)
int maxParticles = 300; //#particles to be spawned
float velOnBounce = 0.9; //amount of velocity retained on wall bounce (mult.) [0.0-1.0]
float minD = 2; //min diameter for a particle
float maxD = 5; //max diameter for a particle
float G = 0.01; //value of big G (higher means gravity is stronger)
int framerate = 60; //guess dumbass

//don't touch this (it will break the program)
int currParticles = 0; //counter for how many particles have been created
particle pArray[] = new particle[maxParticles]; //array of particles
boolean animate = true; //manages if the screen is paused or not (toggles on click)

void setup(){
  fullScreen(); 
  surface.setTitle("Gravity sim");
  frameRate(framerate);
}

void draw(){
  if(animate){
    background(0);
    createParticles();
    drawParticles();
  }
}

void mouseClicked(){
  animate = !animate;
}

void createParticles() { //runs every frame but does stuff only once so it's fine
  while(currParticles<maxParticles){ //creates #maxParticles particles
    pArray[currParticles] = new particle(currParticles); //allocates them in pArray
    currParticles++;
  }
}

void drawParticles(){ //calls drawParticle() every frame for every particle
  for (int i = 0; i<currParticles; i++) {
      pArray[i].drawParticle(); //this function calculates acceleration, speed, pos
    } //and then draws the particle
}

public class particle{
  PVector c; //vector of coords
  PVector v; //vector of velocity
  PVector a; //vector of acceleration
  PVector dir; //dir as a normalized vector
  float veltot; //magnitude of v
  float diameter; //diameter of the particle
  int id; //position of the particle inside pArray (useful to not count itself for gravity)
  float mass; //mass of the particle (equal to the area)
  
  public particle(int id){ //initialize with the pArray position of the particle
    this.id = id;
    this.diameter = random(minD,maxD); //random dimension between the two numbers
    c = new PVector(random(this.diameter/2,width-(this.diameter/2)),random(this.diameter,height-(this.diameter/2))); //random starting pos
    v = new PVector(random(-0.5,0.5),random(-0.5,0.5)); //random starting velocity
    a = new PVector(0,0); //no starting acceleration (it would be nullified anyways at first frame)
    this.veltot = v.mag(); //vtot is the magnitude of the velocity vector
    this.dir = new PVector(0,0); //dir is the vector we populate and normalize to calculate gravity acceleration
    this.mass = PI*pow(this.diameter/2,2); //mass = area
  }
  
  void drawParticle(){
    this.calcPos(); //first calculates the new acc,vel,pos
    noStroke(); //no edges because it looks ugly
    fill(255*((this.c.x)/width),255,255*((this.c.y)/height)); //fancy colors based on x,y pos
    //fill((10-veltot)*25,(10-veltot)*25,255); //the particle gets bluer the speedier it is, a poorly constructed joke on blue shift
    circle(this.c.x,this.c.y,this.diameter); //draws the circle
    //textSize(10);
    //text(this.veltot,this.c.x+this.diameter,this.c.y);
  }
  
  void calcPos(){
    this.AccG(); //calculates sum of gravity accelerations got from all the particles around
    this.v.add(this.a); //adds this acceleration to vel
    this.calcWallBounce(); //modifies the velocity if it's bouncing on a border
    this.c.add(this.v); //adds the velocity to the position
    this.veltot = v.mag(); //calculates the magnitude of the velocity (this is just to display it, serves no purpose)
  }
  
  void AccG(){
    this.cancAcc(); //first nullifies the acceleration the particle had last frame
    for(int i=0;i<currParticles;i++){ //then adds acceleration for every other particle
      if(i != id)this.calcAcc(pArray[i]);
    }
  }
  
  void cancAcc(){
    this.a.set(0,0); //it just sets a.x and a.y as 0
  }
  void calcAcc(particle p2){ //dir calculates the direction of the force, gravity calculates the acceleration (not really the force of gravity)
    this.a.add(dirV(this.c,p2.c).mult(gravity(dist(this,p2),this.mass,p2.mass))); //just adding it
  }
  void calcWallBounce(){ //if outside the border, it flips the velocity and applies multiplier (on the affected axis(es))
    if(this.c.y<this.diameter/2 && this.v.y<0)this.v.y *=-velOnBounce;
    if(this.c.y>height-this.diameter/2 && this.v.y>0)this.v.y *=-velOnBounce;
    if(this.c.x<this.diameter/2 && this.v.x<0)this.v.x *=-velOnBounce;
    if(this.c.x>width-this.diameter/2 && this.v.x>0)this.v.x *=-velOnBounce;
  }
}

PVector dirV(PVector c1,PVector c2){
  PVector ct = new PVector(c2.x,c2.y); //sets temp vector as c2
  ct.sub(new PVector(c1.x,c1.y)); //subtracts c1 getting as a result the distance vector
  return ct.normalize(); //normalizes the vector going from c1 to c2 
} //it's basically a clever way to deal with forces without dealing with angles (PVector ftw)

float dist(particle p1,particle p2){
  PVector tc = new PVector(p2.c.x,p2.c.y); //distance vector to calculate gravity
  tc.sub(new PVector(p1.c.x,p1.c.y)); //same calculatons as above
  return tc.mag(); //but returning the magnitude instead of the normalized vector
  //it returns the distance as a float basically
}

float gravity(float distance,float mass1,float mass2){
  return (G*mass1*mass2)/(mass1*pow(distance,2)); //formula of the acceleration caused by the gravity force
} //notice that we square the distance in the formula so we don't need to put abs() in the dist function
