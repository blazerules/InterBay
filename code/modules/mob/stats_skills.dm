//////////////////////////////////////////////////////////////////////////
//This is the file where all the stats and skills procs are kept.	    //
//The system is kinda barebones now but I hope to rewrite it to  	    //
//be betting in the near future. 								 	    //
//																 	    //
//Stats are pretty generic, skills are kind of specific. 				//
//You should just be able to plop in the proc call wherever you want.   //
//I tried to make it versitile.											//
// - Matt 																//
//////////////////////////////////////////////////////////////////////////

//defines
#define CRIT_SUCCESS_NORM 5
#define CRIT_FAILURE_NORM 5
#define CRIT_SUCCESS 2
#define CRIT_FAILURE 3


//I am aware this is probably the worst possible way of doing it but I'm using this method till I get a better one. - Matt
/mob
	var/str = 10    //strength - used for hitting and lifting.
	var/dex = 10    //dexterity - used for dodging and parrying.
	var/int = 10

    //skills
	var/melee_skill = 50
	var/ranged_skill = 50
	var/medical_skill = 20
	var/engineering_skill = 50

	//crit shit
	var/crit_success_chance = CRIT_SUCCESS_NORM
	var/crit_failure_chance = CRIT_FAILURE_NORM

proc/skillcheck(var/skill, var/requirement, var/show_message, var/mob/user, var/message = "I have failed to do this.")//1 - 100
	if(skill >= requirement)
		if(prob(user.crit_success_chance))
			return CRIT_SUCCESS
		return 1
	else
		if(prob(skill + mood_affect(user, 0, 1)))
			if(prob(user.crit_success_chance))
				return CRIT_SUCCESS
			return 1
		else
			if(show_message)
				to_chat(user, "<span class = 'warning'>[message]</span>")
			if(prob(user.crit_failure_chance))
				return CRIT_FAILURE
			return 0


proc/statscheck(var/stat, var/requirement, var/show_message, var/mob/user, var/message = "I have failed to do this.")//Requirement needs to be 1 through 20
	//var/dice = "1d20"
	if(stat < requirement)
		var/H = rand(1,20)
		H += mood_affect(user, 1)
		if(stat >= H)
			//world << "Rolled and passed."
			return 1
		else
			if(show_message)
				to_chat(user, "<span class = 'warning'>[message]</span>")
			return 0
	else
		//world << "Didn't roll and passed."
		return 1

//having a bad mood fucks your shit up fam.
proc/mood_affect(var/mob/user, var/stat = null, var/skill = null)
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		if(C.happiness <= MOOD_LEVEL_SAD3)
			if(stat)
				return 5
			if(skill)
				return -15


proc/strToDamageModifier(var/strength)
	switch(strength)
		if(1 to 5)
			return 0.5

		if(6 to 11)
			return 1

		if(12 to 15)
			return 1.5

		if(16 to INFINITY)
			return  1.75

proc/strToSpeedModifier(var/strength, var/w_class)//Looks messy. Is messy. Is also only used once. But I don't give a fuuuuuuuuck.
	switch(strength)
		if(1 to 5)
			if(w_class > ITEM_SIZE_NORMAL)
				return 20

		if(6 to 11)
			if(w_class > ITEM_SIZE_NORMAL)
				return 15

		if(12 to 15)
			if(w_class > ITEM_SIZE_NORMAL)
				return 10

		if(16 to INFINITY)
			if(w_class > ITEM_SIZE_NORMAL)
				return 5

//Stats helpers.
/mob/living/carbon/human/proc/add_stats(var/stre, var/dexe, var/inti)//To make adding stats quicker.
	if(stre)
		str = stre
	if(dexe)
		dex = dexe
	if(inti)
		int = inti


/mob/proc/adjustStrength(var/num)
	str += num

/mob/proc/adjustDexterity(var/num)
	dex += num

/mob/proc/adjustInteligence(var/num)
	int += num



//Skill helpers.
/mob/proc/skillnumtodesc(var/skill)
	switch(skill)
		if(0 to 25)
			return "<small><i>pathetic</i></small>"
		if(25 to 45)
			return "unskilled"
		if(45 to 60)
			return pick("alright", "ok", "not bad")
		if(60 to 80)
			return "skilled"
		if(80 to INFINITY)
			return "<b>GOD LIKE</b>"

/mob/living/carbon/human/proc/add_skills(var/melee, var/ranged, var/medical, var/engineering)//To make adding skills quicker.
	if(melee)
		melee_skill = melee
	if(ranged)
		ranged_skill = ranged
	if(medical)
		medical_skill = medical
	if(engineering)
		engineering_skill = engineering

/mob/living/carbon/human/verb/check_skills()//Debug tool for checking skills until I add the icon for it to the HUD.
	set name = "Check Skills"
	set category = "IC"

	var/message = "<big><b>Skills:</b></big>\n"
	message += "I am <b>[skillnumtodesc(melee_skill)]</b> at melee.\n"
	message += "I am <b>[skillnumtodesc(ranged_skill)]</b> with guns.</b></i>\n"
	message += "I am <b>[skillnumtodesc(medical_skill)]</b> with medicine.</b></i>\n"
	message += "I am <b>[skillnumtodesc(engineering_skill)]</b> at engineering.</b></i>\n"

	to_chat(src, message)