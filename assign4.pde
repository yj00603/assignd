PImage title, gameover, gamewin, startNormal, startHovered, restartNormal, restartHovered;
PImage groundhogIdle, groundhogLeft, groundhogRight, groundhogDown;
PImage bg, life, cabbage, soilEmpty, clock, caution, sweethome;
PImage soldier;
PImage[][] soils, stones;
PFont font;

final int GAME_START = 0, GAME_RUN = 1, GAME_OVER = 2, GAME_WIN = 3;
int gameState = 0;

final int GRASS_HEIGHT = 15;
final int SOIL_COL_COUNT = 8;
final int SOIL_ROW_COUNT = 24;
final int SOIL_SIZE = 80;

int[][] soilHealth;

final int START_BUTTON_WIDTH = 144;
final int START_BUTTON_HEIGHT = 60;
final int START_BUTTON_X = 248;
final int START_BUTTON_Y = 360;

float[] cabbageX, cabbageY, soldierX, soldierY, clockX, clockY;
float soldierSpeed = 2f;

final int GAME_INIT_TIMER = 7200;
int gameTimer = GAME_INIT_TIMER;

final float CLOCK_BONUS_SECONDS = 15f;

float playerX, playerY;
int playerCol, playerRow;
final float PLAYER_INIT_X = 4 * SOIL_SIZE;
final float PLAYER_INIT_Y = - SOIL_SIZE;
boolean leftState = false;
boolean rightState = false;
boolean downState = false;
int playerHealth = 2;
final int PLAYER_MAX_HEALTH = 5;
int playerMoveDirection = 0;
int playerMoveTimer = 0;
int playerMoveDuration = 15;

boolean demoMode = false;

void setup() {
	size(640, 480, P2D);
	frameRate(60);
	bg = loadImage("img/bg.jpg");
	title = loadImage("img/title.jpg");
	gameover = loadImage("img/gameover.jpg");
	gamewin = loadImage("img/gamewin.jpg");
	startNormal = loadImage("img/startNormal.png");
	startHovered = loadImage("img/startHovered.png");
	restartNormal = loadImage("img/restartNormal.png");
	restartHovered = loadImage("img/restartHovered.png");
	groundhogIdle = loadImage("img/groundhogIdle.png");
	groundhogLeft = loadImage("img/groundhogLeft.png");
	groundhogRight = loadImage("img/groundhogRight.png");
	groundhogDown = loadImage("img/groundhogDown.png");
	life = loadImage("img/life.png");
	soldier = loadImage("img/soldier.png");
	cabbage = loadImage("img/cabbage.png");
	clock = loadImage("img/clock.png");
	caution = loadImage("img/caution.png");
	sweethome = loadImage("img/sweethome.png");
	soilEmpty = loadImage("img/soils/soilEmpty.png");

	font = createFont("font/font.ttf", 56);
	textFont(font);

	// Load PImage[][] soils
	soils = new PImage[6][5];
	for(int i = 0; i < soils.length; i++){
		for(int j = 0; j < soils[i].length; j++){
			soils[i][j] = loadImage("img/soils/soil" + i + "/soil" + i + "_" + j + ".png");
		}
	}

	// Load PImage[][] stones
	stones = new PImage[2][5];
	for(int i = 0; i < stones.length; i++){
		for(int j = 0; j < stones[i].length; j++){
			stones[i][j] = loadImage("img/stones/stone" + i + "/stone" + i + "_" + j + ".png");
		}
	}

	initGame();
}

void initGame(){

	// Initialize gameTimer
	gameTimer = GAME_INIT_TIMER;

	// Initialize player
	initPlayer();

	// Initialize soilHealth
	initSoils();

	// Initialize soidiers and their position
	initSoldiers();

	// Initialize cabbages and their position
	initCabbages();

	// Requirement #2: Initialize clocks and their position
  initClocks();
}

void initPlayer(){
	playerX = PLAYER_INIT_X;
	playerY = PLAYER_INIT_Y;
	playerCol = (int) playerX / SOIL_SIZE;
	playerRow = (int) playerY / SOIL_SIZE;
	playerMoveTimer = 0;
	playerHealth = 2;
}

void initSoils(){
	soilHealth = new int[SOIL_COL_COUNT][SOIL_ROW_COUNT];

	int[] emptyGridCount = new int[SOIL_ROW_COUNT];

	for(int j = 0; j < SOIL_ROW_COUNT; j++){
		emptyGridCount[j] = ( j == 0 ) ? 0 : floor(random(1, 3));
	}

	for(int i = 0; i < soilHealth.length; i++){
		for (int j = 0; j < soilHealth[i].length; j++) {
			 // 0: no soil, 15: soil only, 30: 1 stone, 45: 2 stones
			float randRes = random(SOIL_COL_COUNT - i);

			if(randRes < emptyGridCount[j]){

				soilHealth[i][j] = 0;
				emptyGridCount[j] --;

			}else{

				soilHealth[i][j] = 15;

				if(j < 8){

					if(j == i) soilHealth[i][j] = 2 * 15;

				}else if(j < 16){

					int offsetJ = j - 8;
					if(offsetJ == 0 || offsetJ == 3 || offsetJ == 4 || offsetJ == 7){
						if(i == 1 || i == 2 || i == 5 || i == 6){
							soilHealth[i][j] = 2 * 15;
						}
					}else{
						if(i == 0 || i == 3 || i == 4 || i == 7){
							soilHealth[i][j] = 2 * 15;
						}
					}

				}else{

					int offsetJ = j - 16;
					int stoneCount = (offsetJ + i) % 3;
					soilHealth[i][j] = (stoneCount + 1) * 15;

				}
			}
		}
	}
}

void initSoldiers(){
	soldierX = new float[6];
	soldierY = new float[6];

	for(int i = 0; i < soldierX.length; i++){
		soldierX[i] = random(-SOIL_SIZE, width);
		soldierY[i] = SOIL_SIZE * ( i * 4 + floor(random(4)));
	}
}

void initCabbages(){
	cabbageX = new float[6];
	cabbageY = new float[6];

	for(int i = 0; i < cabbageX.length; i++){
		cabbageX[i] = SOIL_SIZE * floor(random(SOIL_COL_COUNT));
		cabbageY[i] = SOIL_SIZE * ( i * 4 + floor(random(4)));
	}
}

void initClocks(){
	// Requirement #1: Complete this method based on initCabbages()
	// - Remember to reroll if the randomized position has a cabbage on the same soil!
  clockX = new float[6];
  clockY = new float[6];

  for(int i = 0; i < clockX.length; i++){
    clockX[i] = SOIL_SIZE * floor(random(SOIL_COL_COUNT));
    clockY[i] = SOIL_SIZE * ( i * 4 + floor(random(4)));
    if (clockX[i] == cabbageX[i] && clockY[i] ==cabbageY[i]){
    clockX[i] = SOIL_SIZE * floor(random(SOIL_COL_COUNT));
    clockY[i] = SOIL_SIZE * ( i * 4 + floor(random(4)));
    }
  }
}


void draw() {

	switch (gameState) {

		case GAME_START: // Start Screen
		image(title, 0, 0);
		if(START_BUTTON_X + START_BUTTON_WIDTH > mouseX
	    && START_BUTTON_X < mouseX
	    && START_BUTTON_Y + START_BUTTON_HEIGHT > mouseY
	    && START_BUTTON_Y < mouseY) {

			image(startHovered, START_BUTTON_X, START_BUTTON_Y);
			if(mousePressed){
				gameState = GAME_RUN;
				mousePressed = false;
			}

		}else{

			image(startNormal, START_BUTTON_X, START_BUTTON_Y);

		}

		break;

		case GAME_RUN: // In-Game
		// Background
		image(bg, 0, 0);

		// Sun
	    stroke(255,255,0);
	    strokeWeight(5);
	    fill(253,184,19);
	    ellipse(590,50,120,120);

	    // CAREFUL!
	    // Because of how this translate value is calculated, the Y value of the ground level is actually 0
		pushMatrix();
		translate(0, max(SOIL_SIZE * -22, SOIL_SIZE * 1 - playerY));

		// Ground

		fill(124, 204, 25);
		noStroke();
		rect(0, -GRASS_HEIGHT, width, GRASS_HEIGHT);

		// Soil

		for(int i = 0; i < SOIL_COL_COUNT; i++){
			for(int j = 0; j < SOIL_ROW_COUNT; j++){

				if(soilHealth[i][j] > 0){

					int soilColor = (int) (j / 4);
					int soilAlpha = (int) (min(5, ceil((float)soilHealth[i][j] / (15 / 5))) - 1);

					image(soils[soilColor][soilAlpha], i * SOIL_SIZE, j * SOIL_SIZE);

					if(soilHealth[i][j] > 15){
						int stoneSize = (int) (min(5, ceil(((float)soilHealth[i][j] - 15) / (15 / 5))) - 1);
						image(stones[0][stoneSize], i * SOIL_SIZE, j * SOIL_SIZE);
					}

					if(soilHealth[i][j] > 15 * 2){
						int stoneSize = (int) (min(5, ceil(((float)soilHealth[i][j] - 15 * 2) / (15 / 5))) - 1);
						image(stones[1][stoneSize], i * SOIL_SIZE, j * SOIL_SIZE);
					}

				}else{
					image(soilEmpty, i * SOIL_SIZE, j * SOIL_SIZE);
				}

			}
		}

		// Soil background past layer 24
		for(int i = 0; i < SOIL_COL_COUNT; i++){
			for(int j = SOIL_ROW_COUNT; j < SOIL_ROW_COUNT + 4; j++){
				image(soilEmpty, i * SOIL_SIZE, j * SOIL_SIZE);
			}
		}

		image(sweethome, 0, SOIL_ROW_COUNT * SOIL_SIZE);

		// Cabbages

		for(int i = 0; i < cabbageX.length; i++){

			image(cabbage, cabbageX[i], cabbageY[i]);

			// Requirement #3: Use boolean isHit(...) to detect collision
			if(playerHealth < PLAYER_MAX_HEALTH
         && isHit(playerX, playerY, SOIL_SIZE, SOIL_SIZE, cabbageX[i], cabbageY[i], SOIL_SIZE, SOIL_SIZE) ){

				playerHealth ++;
				cabbageX[i] = cabbageY[i] = -1000;

			}

		}

		// Requirement #1: Clocks

    for(int i = 0; i < clockX.length; i++){

      image(clock, clockX[i], clockY[i]);

      // --- Requirement #3: Use boolean isHit(...) to detect clock <-> player collision
      if(isHit(playerX, playerY, SOIL_SIZE, SOIL_SIZE, clockX[i], clockY[i], SOIL_SIZE, SOIL_SIZE) ){
           
        addTime(15);
        clockX[i] = clockY[i] = -1000;

      }

    }
		// Groundhog

		PImage groundhogDisplay = groundhogIdle;

		// If player is not moving, we have to decide what player has to do next
		if(playerMoveTimer == 0){

			if((playerRow + 1 < SOIL_ROW_COUNT && soilHealth[playerCol][playerRow + 1] == 0) || playerRow + 1 >= SOIL_ROW_COUNT){

				groundhogDisplay = groundhogDown;
				playerMoveDirection = DOWN;
				playerMoveTimer = playerMoveDuration;

			}else{

				if(leftState){

					groundhogDisplay = groundhogLeft;

					// Check left boundary
					if(playerCol > 0){

						if(playerRow >= 0 && soilHealth[playerCol - 1][playerRow] > 0){
							soilHealth[playerCol - 1][playerRow] --;
						}else{
							playerMoveDirection = LEFT;
							playerMoveTimer = playerMoveDuration;
						}

					}

				}else if(rightState){

					groundhogDisplay = groundhogRight;

					// Check right boundary
					if(playerCol < SOIL_COL_COUNT - 1){

						if(playerRow >= 0 && soilHealth[playerCol + 1][playerRow] > 0){
							soilHealth[playerCol + 1][playerRow] --;
						}else{
							playerMoveDirection = RIGHT;
							playerMoveTimer = playerMoveDuration;
						}

					}

				}else if(downState){

					groundhogDisplay = groundhogDown;

					// Check bottom boundary
					if(playerRow < SOIL_ROW_COUNT - 1){

						soilHealth[playerCol][playerRow + 1] --;

					}
				}
			}

		}else{
			// Draw image before moving to prevent offset
			switch(playerMoveDirection){
				case LEFT:	groundhogDisplay = groundhogLeft;	break;
				case RIGHT:	groundhogDisplay = groundhogRight;	break;
				case DOWN:	groundhogDisplay = groundhogDown;	break;
			}
		}

		image(groundhogDisplay, playerX, playerY);

		// If player is now moving?

		if(playerMoveTimer > 0){

			playerMoveTimer --;
			switch(playerMoveDirection){

				case LEFT:
				if(playerMoveTimer == 0){
					playerCol--;
					playerX = SOIL_SIZE * playerCol;
				}else{
					playerX = (float(playerMoveTimer) / playerMoveDuration + playerCol - 1) * SOIL_SIZE;
				}
				break;

				case RIGHT:
				if(playerMoveTimer == 0){
					playerCol++;
					playerX = SOIL_SIZE * playerCol;
				}else{
					playerX = (1f - float(playerMoveTimer) / playerMoveDuration + playerCol) * SOIL_SIZE;
				}
				break;

				case DOWN:
				if(playerMoveTimer == 0){
					playerRow++;
					playerY = SOIL_SIZE * playerRow;
					if(playerRow >= SOIL_ROW_COUNT + 3) gameState = GAME_WIN;
				}else{
					playerY = (1f - float(playerMoveTimer) / playerMoveDuration + playerRow) * SOIL_SIZE;
				}
				break;
			}

		}

		// Soldiers

		for(int i = 0; i < soldierX.length; i++){

			soldierX[i] += soldierSpeed;
			if(soldierX[i] >= width) soldierX[i] = -SOIL_SIZE;

			image(soldier, soldierX[i], soldierY[i]);

			// Requirement #3: Use boolean isHit(...) to detect collision
      if(isHit(playerX, playerY, SOIL_SIZE, SOIL_SIZE, soldierX[i], soldierY[i], SOIL_SIZE, SOIL_SIZE) ){
        
				playerHealth --;

				if(playerHealth == 0){

					gameState = GAME_OVER;

				}else{

					playerX = PLAYER_INIT_X;
					playerY = PLAYER_INIT_Y;
					playerCol = (int) playerX / SOIL_SIZE;
					playerRow = (int) playerY / SOIL_SIZE;
					soilHealth[playerCol][playerRow + 1] = 15;
					playerMoveTimer = 0;

				}

			}
		}

		// Requirement #6:
		drawCaution();

		popMatrix();

		// Depth UI
		drawDepthUI();

		// Timer
		gameTimer --;
		if(gameTimer <= 0) gameState = GAME_OVER;

		// Time UI - Requirement #4
		drawTimerUI();

		// Health UI
		for(int i = 0; i < playerHealth; i++){
			image(life, 10 + i * 70, 10);
		}

		break;

		case GAME_OVER: // Gameover Screen
		image(gameover, 0, 0);
		
		if(START_BUTTON_X + START_BUTTON_WIDTH > mouseX
	    && START_BUTTON_X < mouseX
	    && START_BUTTON_Y + START_BUTTON_HEIGHT > mouseY
	    && START_BUTTON_Y < mouseY) {

			image(restartHovered, START_BUTTON_X, START_BUTTON_Y);
			if(mousePressed){
				gameState = GAME_RUN;
				mousePressed = false;
				initGame();
			}

		}else{

			image(restartNormal, START_BUTTON_X, START_BUTTON_Y);

		}
		break;

		case GAME_WIN: // Gameover Screen
		image(gamewin, 0, 0);
		
		if(START_BUTTON_X + START_BUTTON_WIDTH > mouseX
	    && START_BUTTON_X < mouseX
	    && START_BUTTON_Y + START_BUTTON_HEIGHT > mouseY
	    && START_BUTTON_Y < mouseY) {

			image(restartHovered, START_BUTTON_X, START_BUTTON_Y);
			if(mousePressed){
				gameState = GAME_RUN;
				mousePressed = false;
				initGame();
			}

		}else{

			image(restartNormal, START_BUTTON_X, START_BUTTON_Y);

		}
		break;
		
	}
}

void drawDepthUI(){
	String depthString = (playerRow + 1) + "m";
	textSize(56);
	textAlign(RIGHT, BOTTOM);
	fill(0, 120);
	text(depthString, width + 3, height + 3);
	fill(#ffcc00);
	text(depthString, width, height);
}

void drawTimerUI(){
	String timeString = convertFrameToTimeString(gameTimer); // Requirement #4: Get the mm:ss string using String convertFramesToTimeString(int frames)

	textAlign(LEFT, BOTTOM);

	// Time Text Shadow Effect - You don't have to change this!
	fill(0, 120);
	text(timeString, 3, height + 3);
  fill(getTimeTextColor(gameTimer));
	// Actual Time Text
	text(timeString, 0, height);
}

void addTime(float seconds){					// Requirement #2
 gameTimer += round(seconds * 60);
}

boolean isHit(float ax, float ay, float aw, float ah, float bx, float by, float bw, float bh){
  // Requirement #3
	return  ax + aw > bx &&    
          ax < bx + bw &&    
          ay + ah > by &&    
          ay < by + bh;								
}

String convertFrameToTimeString(int frames){
  String result = "";
  float totalSeconds = float(frames) / 60;
  result += nf(floor(totalSeconds/60), 2);
  result += ":";
  result += nf(floor(totalSeconds%60), 2);
  return result;
}	// Requirement #4



color getTimeTextColor(int frames){
  if(frames >= 7200){
    return #00ffff;
  }else if(frames >= 3600){
    return #ffffff;
  }else if(frames >= 1800){
    return #ffcc00;
  }else if(frames >= 600){
    return #ff6600;
  }
  return #ff0000;
}				// Requirement #5

  //}


//int getEnemyIndexByRow(int row){				// Requirement #6

		// HINT:
		// - If there's a soldier in that row, return that soldier's index in soldierX/soldierY
		// (for example, if soldierY[3] is in that row, return 3)
		// - Return -1 if there's no soldier in that row
   // for(int i = 0; i < soldierX.length; i++){
   //   if (soldierY[i] == row){
	 //   return (i);
    //  }else{
    //    return (-1);
    //  }
 // }
//}

void drawCaution(){								// Requirement #6

	// Draw a caution sign above the enemy under the screen using int getEnemyIndexByRow(int row)

		// HINT:
		// - Use playerRow to calculate the row below the screen
		// - Use the returned value from int getEnemyIndexByRow(int row) to get the soldier's position from soldierX/soldierY arrays
		// - Don't draw anything if int getEnemyIndexByRow(int row) returns -1
}

void keyPressed(){
	if(key==CODED){
		switch(keyCode){
			case LEFT:
			leftState = true;
			break;
			case RIGHT:
			rightState = true;
			break;
			case DOWN:
			downState = true;
			break;
		}
	}else{
		if(key=='t'){
			gameTimer -= 180;
		}
	}
}

void keyReleased(){
	if(key==CODED){
		switch(keyCode){
			case LEFT:
			leftState = false;
			break;
			case RIGHT:
			rightState = false;
			break;
			case DOWN:
			downState = false;
			break;
		}
	}
}
