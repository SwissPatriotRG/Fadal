%
O1(TOOL/FIXTURE OFFSET UTILITY)
(THIS PROGRAM CONVERTS NEGATIVE TOOL LENGTHS THAT)
(ARE RELATIVE TO THE MACHINE TABLE INTO POSITIVE LENGTHS)
(AND CONVERTS FIXTURE OFFSETS BASED ON 3D TASTER LENGTH OFFSET)
G91G1F1.
# CLEAR
# R1 = AZ
(DISTANCE FROM SPINDLE NOSE TO TABLE)
(WHEN SPINDLE IS AT COLD START POSITION)
(UPDATE THIS TO WHATEVER YOUR MACHINE IS)
# V2 = H99
# IF V2 GE 0 THEN GOTO :ZEROTOOLNOTSET
(STARTING TOOL NUMBER)
# V3 = 1
(NUMBER OF TOOLS CONVERTED)
# V4 = 0
N16(NUMBER OF TOOLS IN TOOL TABLE)
# V5 = 98



#:CONVERTNEXTTOOL
G91Z-0.0001
# IF V3 GT V5 THEN GOTO :ENDMESSAGE
# IF H(V3) GE 0 THEN GOTO :NEXTTOOL
# V10 = H(V3) - V2
# H(V3) = V10
# V4 = V4 + 1
# PRINT "CONVERTED TOOL:", V3, "TO POSITIVE OFFSET:", V10
# GOTO :NEXTTOOL
#:NEXTTOOL
G91Z0.0001
# V3 = V3 + 10
# GOTO :CONVERTNEXTTOOL


#:ENDMESSAGE
# IF V4 EQ 0 THEN GOTO :NOTOOLS
# PRINT "CONVERTED", V4, "TOOLS TO POSITIVE LENGTH"
# GOTO :FIXTUREOFFSETSELECT


#:NOTOOLS
# PRINT "NO TOOLS WERE CONVERTED. END OF TOOL TABLE REACHED."
# GOTO :FIXTUREOFFSETSELECT


#:FIXTUREOFFSETSELECT
#PRINT ""
#PRINT "FIXTURE Z OFFSET ADJUSTMENT UTILITY"
#PRINT ""
#PRINT "ONLY DO THIS ONCE PER FIXTURE THAT WAS PROBED!"
#PRINT "SELECT WORK OFFSET NUMBER, OR JUST ENTER TO EXIT."
#PRINT ""
#INPUT V12
#IF V12 GT 0 THEN GOTO :FIXTUREOFFSETFIX
#GOTO :END


#:FIXTUREOFFSETFIX
(3D TASTER TOOL OFFSET)
# V6 = H98

#IF V6 LE 0 THEN GOTO :TOOLERROR
(GET THE FIXTURE OFFSET FROM THE INPUT)
#V7 = FZ(V12)
#V8 = V7 - V6
#V11 = v8 - V2
# IF V11 LE 0 THEN GOTO :FIXTUREERROR

#PRINT ""
#PRINT ""
#PRINT ""
#PRINT "Z POSITION OF FIXTURE OFFSET: ", V12
#PRINT "WILL BE UPDATED FROM: ", V7, "TO: ", V8
#PRINT "THIS IS ", V11, " INCHES ABOVE THE TABLE"
#PRINT "UPDATE FIXTURE OFFSET? (1 = YES, ENTER = NO)"
#PRINT ""
#INPUT V13
#IF V13 NE 1 THEN GOTO :FIXTUREOFFSETSELECT
#FZ(V12) = V7 - V6
#PRINT "FIXTURE ", V12, " ADJUSTED!"
#GOTO :FIXTUREOFFSETSELECT


#:ZEROTOOLNOTSET
#PRINT ""
#PRINT "!!!!!!!!!!!!!!!!!!!!!!!ERROR!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
#PRINT "NONE OR POSITIVE OFFSET SET FOR SPINDLE NOSE(GAGE LINE)!"
#PRINT "TOOL 99 SHOULD BE MACHINE Z POSITION AS IF THE SPINDLE
#PRINT "NOSE WAS SITTING ON THE TABLE OR A SIMILAR SUITABLE"
#PRINT "DATUM ON TABLE THAT TOOL LENGTHS ARE ALSO MEASURED FROM."
#PRINT "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
#PRINT ""
#INPUT V12
#GOTO :END


#:TOOLERROR
#PRINT ""
#PRINT ""
#PRINT ""
#PRINT "!!!!!!!!!!!!!!!!!!!!!!!ERROR!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
#PRINT "REFERENCE TOOL 98 DOES NOT HAVE A SUITABLE LENGTH!"
#PRINT "REFERENCE LENGTH MUST BE POSITIVE LENGTH FROM GAGE LINE."
#PRINT "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
#PRINT ""
#INPUT V12
#GOTO :END


#:FIXTUREERROR
#PRINT ""
#PRINT ""
#PRINT "!!!!!!!!!!!!!!!!!!!!!!!ERROR!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
#PRINT "FIXTURE OFFSET", V12, " WOULD BE "
#PRINT V11, " INCHES BELOW THE TABLE!!!"
#PRINT "NO ADJUSTMENT HAS BEEN MADE"
#PRINT "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
#PRINT ""
#INPUT V12
#GOTO :FIXTUREOFFSETSELECT


#:END
%

