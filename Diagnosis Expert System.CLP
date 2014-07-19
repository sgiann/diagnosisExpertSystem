;AEM: 
;Giannouloudis Stergios
;Empeiro Systhma Iatrikhs Diagnwshs


;;O kanonas "fatigue" isws na mhn ekteleite swsta.



;Q/A Function
;------------
(deffunction ask-question (?question $?allowed-values)
   (printout t ?question)
   (bind ?answer (read))
   (if (lexemep ?answer) 
       then (bind ?answer (lowcase ?answer)))
   (while (not (member ?answer ?allowed-values)) do
      (printout t ?question)
      (bind ?answer (read))
      (if (lexemep ?answer) 
          then (bind ?answer (lowcase ?answer))))
   ?answer)

;yes-or-no function

(deffunction yes-or-no-p (?question)
   (bind ?response (ask-question ?question yes no y n))
   (if (or (eq ?response yes) (eq ?response y))
       then TRUE 
       else FALSE))




;;Arxika rwtame ton as8enh an exei symptwmata.
;;An den exei, orizoume to "health-state"->fine

(defrule has-symptom "Asking the patient if he/she has any symptoms"
	(declare (salience 50))
	(not (has-any-symptoms ?))
	=>
	(if (yes-or-no-p "Do you have any symptoms? (yes/no)")
	then (assert (has-any-symptoms yes))
	else (assert (health-state fine)) ) 
)





;;Ksekiname me thn erwthsh gia "headache"

;;Arxika rwtame ton as8enh an exei kapoio "head-symptom"
;;kai epeita an afto einai "headache". An apanthsei "no"
;;tote ton rwtame an exei kati paromoio.

(defrule head-symptom "Asking the patient if he has any head symptoms"
	(declare (salience 40))
	(has-any-symptoms yes)
	=>
	(if (yes-or-no-p "Do you have any head symptom? (yes/no)")
	then
	    (if (yes-or-no-p "Do you have headache? (yes/no)")
	    then (assert (headache yes))
	    else (bind ?response (ask-question "Any other head symptoms? (pain_head,migraine,(no))" pain_head migraine no) )
		 (if (eq ?response no)
		 then (assert (headache no))
		 else (if (eq ?response pain_head)
			then (assert (headache yes))
			else (if ( eq ?response migraine)
				then (assert (headache yes))
			        else (assert (headache  no)) ) ) ) ) ) )



;;Erwthsh gia "fever"

;;Omoia rwtame an o as8enhs exei "fever"
;;An apanthsei "no" ton rwtame gia at alla dyo paromoia symptomata

(defrule fever "Asking the patient if he has temperature"
	(declare (salience 35))
	(has-any-symptoms yes)
	(headache yes)
	=>
	(if (yes-or-no-p "Do you have fever? (yes/no)")
	then (assert (fever yes))
	else (bind ?response (ask-question "Any symptoms like hyperthermia or pyrexia (no if you dont have any)?" hyperthermia pyrexia no) )
(if (eq ?response no)
then (assert (fever no))
else
			(if (eq ?response hyperthermia)
			    then (assert (fever yes))
			    else (if (eq ?response pyrexia)
				then (assert (fever yes) ) ) ) ) ) )




;;Se afto to shmeio an DEN exei "headache" kai "fever" den borei na exei oute "HIV" oute "Flu"
;;Opote rwtame gia ta symptwmata tou "Common Cold"

;;Edw oi erwthseis ginontai sth seira.

(defrule cc "Checking if the patience has Common Cold"
	(declare (salience 30))
	(has-any-symptoms yes)
	(headache no)
	(fever no)
	=>
	(if (yes-or-no-p "Do you have Nasal_discharge?(yes/no)")
	then  (assert (nd yes))
	      (if (yes-or-no-p "Are you sneezing?(yes/no)")
		then  (assert (sneezing yes))
		      (if (yes-or-no-p "Are you shivering?(yes/no)")
			then  (assert (shivering yes))
			else  (assert (shivering no))
			      (assert (health-state-unknown)) )
		else (assert (sneezing no))
		     (assert (health-state unknown)) )
	else (assert (nd no))
	     (assert (health-state unknown))  )    )

;;Dhladh an den exei estw kai ena apo ta symptwmata
;;den borei na exei "Common Cold" kai dedomenou tou "headache" kai "fever" 
;;den boroume na kseroume ti exei opote kataxwroume "unknown health state"


;;Edw 8a rwthsoume gia "shore-throat"
;;Se afto ton kanona proteinontai ston as8enh oles oi dynates apanthseis me mia erwthsh
;;An exei ponolemo 8a kanoume th diagnwsh gia CC, h HIV parakatw

(defrule sore_throat "Asking the patient if he has sore throat"
	(declare (salience 25))
	(has-any-symptoms yes)
	;(not (health-state unknown))
	=>
	(bind ?response (ask-question "Does your throat aches? (yes,no,sore_throat,pain_throat,throat_sore)" yes no sore_throat pain_throat throat_sore) )
	(if (or (eq ?response yes) (eq ?response sore_throat) (eq ?response pain_throat) (eq ?response throat_sore)	)
	then (assert (sore-throat yes))
	else (assert (sore-throat  no)) ) )



;;Edw boroume na apanthsoume an exei CC

(defrule cc_diagnosis "Saying that the patient has Common Cold"
	(declare (salience 20))
	(has-any-symptoms yes)
	(sore-throat yes)
	(shivering yes)
	(sneezing yes)
	(nd yes)
	=>
	(printout t crlf crlf)
	(printout t "You have a Common Cold")
	(printout t crlf crlf)   )

	


;;Se afto to shmeio den borei na exei common cold
;;Eksetazoume an exei HIV

(defrule hiv "Checking if the patience has HIV"
	(declare (salience 15))
	(has-any-symptoms yes)
	(headache yes)
	(fever yes)
	(sore-throat yes)
	=>
	(if (yes-or-no-p "Do you have Rash?(yes/no)")
	then (assert (rash yes))
	     (printout t crlf crlf)
	     (printout t "You have HIV")
	     (printout t crlf crlf)
	else (assert (rash  no)) ) )




;;prepei na eksetasoume an o asthenhs exei "Fatigue"

;;Rwtame ton as8enh an exei Fatigue kai an apanthsei "no"
;;tote ton rwtame gia paromoia symptomata
;;proteinontas tou ta.

(defrule fatigue "Asking the patient if he has fatigue or sth relative"
	(declare (salience 10))
	(has-any-symptoms yes)
	(headache yes)
	(fever yes)
	(sore-throat no)
	=>
	(if (yes-or-no-p "Do you have Fatigue?(yes/no)")
	then (assert (fatigue yes))
	else (bind ?response (ask-question "Any similar symptoms? (exhaustion, tiredness, weariness, no)"  exhaustion tiredness weariness))
		(if (or (eq ?response exhaustion) (eq ?response tiredness) (eq ?response weriness) )
			then (assert (fatigue yes))
			else (assert (fatigue  no))
			     (assert (health-state unknown))  ) ) )




;;Menei h periptwsh o as8enhs na exei Flu

(defrule flu "Checking if the patient has the Flu"
	(declare (salience 9))
	(has-any-symptoms yes)
	(headache yes)
	(fever yes)
	(fatigue yes)
	;(sore-throat no)
	=>
	(if (yes-or-no-p "Do you have Nasal_discharge?(yes/no)")
	then  (assert (nd yes))
	      (printout t crlf crlf)
	      (printout t "You have the Flu")
	      (printout t crlf crlf) 
	else (assert (health-state unknown))  ) )


;Anakoinwnoume oti einai kala

(defrule diag1 "Rule that the patient is fine"
	(health-state fine)
	=>
	(printout t crlf crlf)
	(printout t "You are Fine")
	(printout t crlf crlf)  )

;Anakoinwnoume oti den kseroume ti exei

(defrule diag2 "Rule that the patient has sth we don't know"
	(health-state unknown)
	=>
	(printout t crlf crlf)
	(printout t "You have an unknown heath problem")
	(printout t crlf crlf)  )
