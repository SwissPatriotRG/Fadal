/**
  Copyright (C) 2012-2021 by Autodesk, Inc.
  All rights reserved.

  Fadal post processor configuration.

  $Revision: 43151 08c79bb5b30997ccb5fb33ab8e7c8c26981be334 $
  $Date: 2021-02-19 00:25:13 $
  
  FORKID {D3B70418-781B-4cfb-8CD2-98E9C897515A}
*/

description = "Reini's Fadal";
vendor = "Fadal";
vendorUrl = "http://www.fadal.com";
legal = "Copyright (C) 2012-2021 by Autodesk, Inc.";
certificationLevel = 2;
minimumRevision = 45702;

longDescription = "Generic milling post for Fadal.";

extension = "nc";
programNameIsInteger = true;
setCodePage("ascii");

capabilities = CAPABILITY_MILLING;
tolerance = spatial(0.002, MM);

minimumChordLength = spatial(0.25, MM);
minimumCircularRadius = spatial(0.01, MM);
maximumCircularRadius = spatial(1000, MM);
minimumCircularSweep = toRad(0.01);
maximumCircularSweep = toRad(180);
allowHelicalMoves = true;
allowedCircularPlanes = undefined; // allow any circular motion
highFeedrate = (unit == IN) ? 400 : 5000;

// user-defined properties
properties = {
    writeMachine: {
        title: "Write machine",
        description: "Output the machine settings in the header of the code.",
        group: 0,
        type: "boolean",
        value: true,
        scope: "post"
    },
    writeTools: {
        title: "Write tool list and check negative Lengths",
        description: "Output a tool list in the header of the code and check negative tool lengths",
        group: 0,
        type: "boolean",
        value: true,
        scope: "post"
    },
    preloadTool: {
        title: "Preload tool",
        description: "Preloads the next tool at a tool change (if any).",
        group: 1,
        type: "boolean",
        value: false,
        scope: "post"
    },
    optionallyCycleToolsAtStart: {
        title: "Optionally cycle tools at start",
        description: "Cycle through each tool used at the beginning of the program.",
        group: 2,
        type: "boolean",
        value: false,
        scope: "post"
    },
    optionallyMeasureToolsAtStart: {
        title: "Optionally measure tools at start",
        description: "Measure each tool used at the beginning of the program.",
        group: 2,
        type: "boolean",
        value: true,
        scope: "post"
    },
    toolBreakageTolerance: {
        title: "Tool breakage tolerance",
        description: "Specifies the tolerance for which tool break detection will raise an alarm.",
        group: 2,
        type: "spatial",
        value: 0.1,
        scope: "post"
    },
    toolSetterOffset: {
        title: "Tool Setter WCS",
        description: "E Number of the tool setter probe center",
        group: 2,
        type: "integer",
        value: 47,
        scope: "post"
    },
    longToolClearance: {
        title: "Long Tool Clearance",
        description: "Move to corner and raise tool after change",
        group: 2,
        type: "boolean",
        value: false,
        scope: "post"
    },
    showSequenceNumbers: {
        title: "Use sequence numbers",
        description: "Use sequence numbers for each block of outputted code.",
        group: 1,
        type: "boolean",
        value: true,
        scope: "post"
    },
    sequenceNumberStart: {
        title: "Start sequence number",
        description: "The number at which to start the sequence numbers.",
        group: 1,
        type: "integer",
        value: 10,
        scope: "post"
    },
    sequenceNumberIncrement: {
        title: "Sequence number increment",
        description: "The amount by which the sequence number is incremented by in each block.",
        group: 1,
        type: "integer",
        value: 5,
        scope: "post"
    },
    optionalStop: {
        title: "Optional stop",
        description: "Outputs optional stop code during when necessary in the code.",
        type: "boolean",
        value: true,
        scope: "post"
    },
    onlyENumbers: {
        title: "Output E-code for WCS offset",
        description: "Set to 'Yes' to output E-codes or 'No' to output G54-G59 for WCS offsets.",
        type: "boolean",
        value: true,
        scope: "post"
    },
    separateWordsWithSpace: {
        title: "Separate words with space",
        description: "Adds spaces between words if 'yes' is selected.",
        type: "boolean",
        value: true,
        scope: "post"
    },
    format: {
        title: "Format style output",
        description: "Enter 1 for FADAL style formatting, 2 for Fanuc style.",
        type: "integer",
        value: 2,
        scope: "post"
    },
    useRigidTapping: {
        title: "Use rigid tapping",
        description: "'Yes' enables rigid tapping (G84.1), 'No' uses standard tapping (G84).",
        type: "boolean",
        value: true,
        scope: "post"
    },
    hasAAxis: {
        title: "Has rotary table",
        description: "Select 'Yes' to enable the A-axis rotary table.",
        type: "boolean",
        value: false,
        scope: "post"
    },
    useInverseTime: {
        title: "Use inverse time feedrates",
        description: "'Yes' enables inverse time feedrates, 'No' outputs DPM feedrates.",
        type: "boolean",
        value: true,
        scope: "post"
    },
    rotaryScale: {
        title: "Rotary table scale",
        description: "Select either Rotary (0-360) with sign determining direction or Linear (continuous).",
        type: "enum",
        values: [
            { title: "Rotary", id: "rotary" },
            { title: "Linear", id: "linear" }
        ],
        value: "rotary",
        scope: "post"
    },
    safePositionMethod: {
        title: "Safe Retracts",
        description: "Select your desired retract option. 'Clearance Height' retracts to the operation clearance height.",
        type: "enum",
        values: [
            // {title:"G28", id: "G28"},
            // {title:"G53", id: "G53"},
            { title: "Clearance Height", id: "clearanceHeight" },
            { title: "Machine Home", id: "machineHome" }
        ],
        value: "machineHome",
        scope: "post"
    }
};

var singleLineCoolant = false; // specifies to output multiple coolant codes in one line rather than in separate lines
// samples:
// {id: COOLANT_THROUGH_TOOL, on: 88, off: 89}
// {id: COOLANT_THROUGH_TOOL, on: [8, 88], off: [9, 89]}
var coolants = [
    { id: COOLANT_FLOOD, on: 8 },
    { id: COOLANT_MIST, on: 7 },
    { id: COOLANT_THROUGH_TOOL },
    { id: COOLANT_AIR },
    { id: COOLANT_AIR_THROUGH_TOOL },
    { id: COOLANT_SUCTION },
    { id: COOLANT_FLOOD_MIST },
    { id: COOLANT_FLOOD_THROUGH_TOOL },
    { id: COOLANT_OFF, off: 9 }
];

var gFormat = createFormat({ prefix: "G", decimals: 1 });
var mFormat = createFormat({ prefix: "M", decimals: 0 });
var hFormat = createFormat({ prefix: "H", decimals: 0 });
var dFormat = createFormat({ prefix: "D", decimals: 0 });
var eFormat = createFormat({ prefix: "E", decimals: 0 });

var xyzFormat = createFormat({ decimals: (unit == MM ? 3 : 4), forceDecimal: true });
var abcFormat = createFormat({ decimals: 3, forceDecimal: true, scale: DEG });
var feedFormat = createFormat({ decimals: (unit == MM ? 1 : 2), forceDecimal: true });
var tapFeedFormat = createFormat({ decimals: 3, forceDecimal: true });
var toolFormat = createFormat({ decimals: 0 });
var rpmFormat = createFormat({ decimals: 1, forceDecimal: false });
var milliFormat = createFormat({ decimals: 0 }); // milliseconds // range 1-9999
var rFormat = createFormat({ decimals: (unit == MM ? 3 : 4), forceDecimal: true, forceSign: true });
var taperFormat = createFormat({ decimals: 1, scale: DEG });

var xOutput = createVariable({ prefix: "X" }, xyzFormat);
var yOutput = createVariable({ prefix: "Y" }, xyzFormat);
var zOutput = createVariable({ onchange: function () { retracted = false; }, prefix: "Z" }, xyzFormat);
var aOutput = createVariable({ prefix: "A" }, abcFormat);
var bOutput = createVariable({ prefix: "B" }, abcFormat);
var cOutput = createVariable({ prefix: "C" }, abcFormat);
var feedOutput = createVariable({ prefix: "F" }, feedFormat);
var tapFeedOutput = createVariable({ prefix: "F", force: true }, tapFeedFormat);
var sOutput = createVariable({ prefix: "S", force: true }, rpmFormat);
var dOutput = createVariable({}, dFormat);

// circular output
var iOutput = createReferenceVariable({ prefix: "I" }, xyzFormat);
var jOutput = createReferenceVariable({ prefix: "J" }, xyzFormat);
var kOutput = createReferenceVariable({ prefix: "K" }, xyzFormat);

var gMotionModal = createModal({}, gFormat); // modal group 1 // G0-G3, ...
var gPlaneModal = createModal({ onchange: function () { gMotionModal.reset(); } }, gFormat); // modal group 2 // G17-19
var gAbsIncModal = createModal({}, gFormat); // modal group 3 // G90-91
var gFeedModeModal = createModal({}, gFormat); // modal group 5 // G93-94
var gUnitModal = createModal({}, gFormat); // modal group 6 // G20-21
var gCycleModal = createModal({}, gFormat); // modal group 9 // G81, ...
var gRetractModal = createModal({}, gFormat); // modal group 10 // G98-99
var gAccDecModal = createModal({}, gFormat); // modal group D // G8-G9

var WARNING_WORK_OFFSET = 0;

// fixed settings
var maxRPM = 99999;
var maxTappingRPM = 3000; // s/b 3000 for 10k spindle, 1500 for 7.5k spindle

// collected state
var sequenceNumber;
var currentWorkOffset;
var optionalSection = false;
var tapping = false;
var leftTapping = false;
var retracted = false; // specifies that the tool has been retracted to the safe plane

/**
  Writes the specified block.
*/
function writeBlock() {
    var text = formatWords(arguments);
    if (!text) {
        return;
    }
    if (getProperty("showSequenceNumbers")) {
        if (optionalSection) {
            if (text) {
                writeWords("/", "N" + sequenceNumber, text);
            }
        } else {
            writeWords2("N" + sequenceNumber, arguments);
        }
        sequenceNumber += getProperty("sequenceNumberIncrement");
    } else {
        if (optionalSection) {
            writeWords2("/", arguments);
        } else {
            writeWords(arguments);
        }
    }
}

/**
  Output a comment.
*/
function writeComment(text) {
    writeln("(" + String(text).toUpperCase() + ")");
}

function onOpen() {

    if (getProperty("hasAAxis")) { // note: setup your machine here
        var aaxis;
        if (getProperty("rotaryScale") == "linear") {
            aAxis = createAxis({ coordinate: 0, table: true, axis: [1, 0, 0], cyclic: true });
        } else {
            aAxis = createAxis({ coordinate: 0, table: true, axis: [1, 0, 0], range: [0, 360], cyclic: true });
        }
        machineConfiguration = new MachineConfiguration(aAxis);

        setMachineConfiguration(machineConfiguration);
        optimizeMachineAngles2(1); // map tip mode
    }

    if (!machineConfiguration.isMachineCoordinate(0)) {
        aOutput.disable();
    }
    if (!machineConfiguration.isMachineCoordinate(1)) {
        bOutput.disable();
    }
    if (!machineConfiguration.isMachineCoordinate(2)) {
        cOutput.disable();
    }

    if (getProperty("format") == 1) {
        dOutput = createVariable({}, hFormat);
    }

    if (highFeedrate <= 0) {
        error(localize("You must set 'highFeedrate' because axes are not synchronized for rapid traversal."));
        return;
    }

    if (!getProperty("separateWordsWithSpace")) {
        setWordSeparator("");
    }

    sequenceNumber = getProperty("sequenceNumberStart");
    writeln("%");

    if (programName) {
        var programId;
        try {
            programId = getAsInt(programName);
        } catch (e) {
            error(localize("Program name must be a number."));
        }
        if (!((programId >= 1) && (programId <= 9999))) {
            error(localize("Program number is out of range."));
        }
        var oFormat = createFormat({ width: 4, zeropad: true, decimals: 0 });
        writeln(
            "O" + oFormat.format(programId) +
            conditional(programComment, " (" + String(programComment).toUpperCase() + ")")
        );
    } else {
        error(localize("Program name has not been specified."));
    }

    // dump machine configuration
    var vendor = machineConfiguration.getVendor();
    var model = machineConfiguration.getModel();
    var description = machineConfiguration.getDescription();

    if (getProperty("writeMachine") && (vendor || model || description)) {
        writeComment(localize("Machine"));
        if (vendor) {
            writeComment("  " + localize("vendor") + ": " + vendor);
        }
        if (model) {
            writeComment("  " + localize("model") + ": " + model);
        }
        if (description) {
            writeComment("  " + localize("description") + ": " + description);
        }
    }

    // dump tool information
    if (getProperty("writeTools")) {
        var zRanges = {};
        if (is3D()) {
            var numberOfSections = getNumberOfSections();
            for (var i = 0; i < numberOfSections; ++i) {
                var section = getSection(i);
                var zRange = section.getGlobalZRange();
                var tool = section.getTool();
                if (zRanges[tool.number]) {
                    zRanges[tool.number].expandToRange(zRange);
                } else {
                    zRanges[tool.number] = zRange;
                }
            }
        }

        var tools = getToolTable();
        if (tools.getNumberOfTools() > 0) {
            for (var i = 0; i < tools.getNumberOfTools(); ++i) {
                var tool = tools.getTool(i);
                var comment = "T" + toolFormat.format(tool.number) + "  " +
                    "D=" + xyzFormat.format(tool.diameter) + " " +
                    localize("CR") + "=" + xyzFormat.format(tool.cornerRadius);
                if ((tool.taperAngle > 0) && (tool.taperAngle < Math.PI)) {
                    comment += " " + localize("TAPER") + "=" + taperFormat.format(tool.taperAngle) + localize("deg");
                }
                if (zRanges[tool.number]) {
                    comment += " - " + localize("ZMIN") + "=" + xyzFormat.format(zRanges[tool.number].getMinimum());
                }
                comment += " - " + getToolTypeName(tool.type);
                writeComment(comment);
            }
        }
        // Tool Height Check!!!
        writeComment("Correcting negative tool lengths");
        if (tools.getNumberOfTools() > 0) {
            for (var i = 0; i < tools.getNumberOfTools(); ++i) {
                var tool = tools.getTool(i);
                var lengthCheck = "# IF H" + toolFormat.format(tool.number) + " < 1 THEN H" + toolFormat.format(tool.number) + " = H" + toolFormat.format(tool.number) + " - H99"
                writeBlock(lengthCheck);
            }
        }
    }

    if ((getNumberOfSections() > 0) && (getSection(0).workOffset == 0)) {
        for (var i = 0; i < getNumberOfSections(); ++i) {
            if (getSection(i).workOffset > 0) {
                error(localize("Using multiple work offsets is not possible if the initial work offset is 0."));
                return;
            }
        }
    }

    // absolute coordinates and feed per min
    if (getProperty("format") == 1) {
        writeBlock(gAbsIncModal.format(90), gFeedModeModal.format(94), gPlaneModal.format(17), hFormat.format(0), eFormat.format(0));
    } else {
        writeBlock(gAbsIncModal.format(90), gFeedModeModal.format(94), gPlaneModal.format(17));
    }

    switch (unit) {
        case IN:
            writeBlock(gUnitModal.format(20));
            break;
        case MM:
            writeBlock(gUnitModal.format(21));
            break;
    }

}


function onComment(message) {
    writeComment(message);
}

/** Force output of X, Y, and Z. */
function forceXYZ() {
    xOutput.reset();
    yOutput.reset();
    zOutput.reset();
}

/** Force output of A, B, and C. */
function forceABC() {
    aOutput.reset();
    bOutput.reset();
    cOutput.reset();
}

/** Force output of X, Y, Z, A, B, C, and F on next output. */
function forceAny() {
    forceXYZ();
    forceABC();
    previousDPMFeed = 0;
    feedOutput.reset();
}

var currentWorkPlaneABC = undefined;

function forceWorkPlane() {
    currentWorkPlaneABC = undefined;
}

function setWorkPlane(abc) {
    if (!machineConfiguration.isMultiAxisConfiguration()) {
        return; // ignore
    }

    if (!((currentWorkPlaneABC == undefined) ||
        abcFormat.areDifferent(abc.x, currentWorkPlaneABC.x) ||
        abcFormat.areDifferent(abc.y, currentWorkPlaneABC.y) ||
        abcFormat.areDifferent(abc.z, currentWorkPlaneABC.z))) {
        return; // no change
    }

    onCommand(COMMAND_UNLOCK_MULTI_AXIS);

    writeRetract(Z);

    // get table rotations on a rotary scale
    var endABC = getABCDir(abc.x, abc.y, abc.z);

    writeBlock(
        gMotionModal.format(0),
        conditional(machineConfiguration.isMachineCoordinate(0), "A" + abcFormat.format(endABC.x)),
        conditional(machineConfiguration.isMachineCoordinate(1), "B" + abcFormat.format(endABC.y)),
        conditional(machineConfiguration.isMachineCoordinate(2), "C" + abcFormat.format(endABC.z))
    );

    onCommand(COMMAND_LOCK_MULTI_AXIS);

    previousABC = endABC;
    currentWorkPlaneABC = abc;
}

var closestABC = false; // choose closest machine angles
var currentMachineABC;

function getWorkPlaneMachineABC(workPlane) {
    var W = workPlane; // map to global frame

    var abc = machineConfiguration.getABC(W);
    if (closestABC) {
        if (currentMachineABC) {
            abc = machineConfiguration.remapToABC(abc, currentMachineABC);
        } else {
            abc = machineConfiguration.getPreferredABC(abc);
        }
    } else {
        abc = machineConfiguration.getPreferredABC(abc);
    }

    try {
        abc = machineConfiguration.remapABC(abc);
        currentMachineABC = abc;
    } catch (e) {
        error(
            localize("Machine angles not supported") + ":"
            + conditional(machineConfiguration.isMachineCoordinate(0), " A" + abcFormat.format(abc.x))
            + conditional(machineConfiguration.isMachineCoordinate(1), " B" + abcFormat.format(abc.y))
            + conditional(machineConfiguration.isMachineCoordinate(2), " C" + abcFormat.format(abc.z))
        );
    }

    var direction = machineConfiguration.getDirection(abc);
    if (!isSameDirection(direction, W.forward)) {
        error(localize("Orientation not supported."));
    }

    if (!machineConfiguration.isABCSupported(abc)) {
        error(
            localize("Work plane is not supported") + ":"
            + conditional(machineConfiguration.isMachineCoordinate(0), " A" + abcFormat.format(abc.x))
            + conditional(machineConfiguration.isMachineCoordinate(1), " B" + abcFormat.format(abc.y))
            + conditional(machineConfiguration.isMachineCoordinate(2), " C" + abcFormat.format(abc.z))
        );
    }

    var tcp = false;
    if (tcp) {
        setRotation(W); // TCP mode
    } else {
        var O = machineConfiguration.getOrientation(abc);
        var R = machineConfiguration.getRemainingOrientation(abc, W);
        setRotation(R);
    }

    return abc;
}

function isProbeOperation() {
    return hasParameter("operation-strategy") &&
        (getParameter("operation-strategy") == "probe");
}

function onSection() {
    var forceToolAndRetract = optionalSection && !currentSection.isOptional();
    optionalSection = currentSection.isOptional();

    var insertToolCall = isFirstSection() ||
        currentSection.getForceToolChange && currentSection.getForceToolChange() ||
        (tool.number != getPreviousSection().getTool().number);

    retracted = false;
    var newWorkOffset = isFirstSection() ||
        (getPreviousSection().workOffset != currentSection.workOffset); // work offset changes
    var newWorkPlane = isFirstSection() ||
        !isSameDirection(getPreviousSection().getGlobalFinalToolAxis(), currentSection.getGlobalInitialToolAxis()) ||
        (currentSection.isOptimizedForMachine() && getPreviousSection().isOptimizedForMachine() &&
            Vector.diff(getPreviousSection().getFinalToolAxisABC(), currentSection.getInitialToolAxisABC()).length > 1e-4) ||
        (!machineConfiguration.isMultiAxisConfiguration() && currentSection.isMultiAxis()) ||
        (!getPreviousSection().isMultiAxis() && currentSection.isMultiAxis() ||
            getPreviousSection().isMultiAxis() && !currentSection.isMultiAxis()); // force newWorkPlane between indexing and simultaneous operations

    // Define Machining modes
    tapping = hasParameter("operation:cycleType") &&
        ((getParameter("operation:cycleType") == "tapping") ||
            (getParameter("operation:cycleType") == "right-tapping") ||
            (getParameter("operation:cycleType") == "left-tapping") ||
            (getParameter("operation:cycleType") == "tapping-with-chip-breaking"));
    if (tapping) {
        leftTapping = (getParameter("operation:cycleType") == "left-tapping") ||
            (tool.type == TOOL_TAP_LEFT_HAND);
    }

    if (insertToolCall || newWorkOffset || newWorkPlane) {

        // stop spindle before retract during tool change
        if (insertToolCall && !isFirstSection()) {
            onCommand(COMMAND_STOP_SPINDLE);
        }

        // retract to safe plane
        writeRetract(Z);
    }

    writeln("");

    if (hasParameter("operation-comment")) {
        var comment = getParameter("operation-comment");
        if (comment) {
            writeComment(comment);
        }
    }

    if (insertToolCall) {
        forceWorkPlane();

        setCoolant(COOLANT_OFF);

        if (!isFirstSection() && getProperty("optionalStop")) {
            onCommand(COMMAND_OPTIONAL_STOP);
        }

        if (tool.number > 99) {
            warning(localize("Tool number exceeds maximum value."));
        }

        if (getProperty("longToolClearance")) {
            var words = []; // store all retracted axes in an array
            writeComment("Moving the work away from the carousel");
            // define home positions
            var _xHome;
            var _yHome;
            _xHome = toPreciseUnit(-15, IN);
            _yHome = toPreciseUnit(8, IN);
            words.push("X" + xyzFormat.format(_xHome));
            xOutput.reset();
            words.push("Y" + xyzFormat.format(_yHome));
            yOutput.reset();

            gMotionModal.reset();
            gAbsIncModal.reset();
            writeBlock(gFormat.format(53), words);
            writeBlock("T" + toolFormat.format(tool.number), mFormat.format(6));
            writeComment("Move Z Up");
            writeBlock(gAbsIncModal.format(53), "Z" + xyzFormat.format(toPreciseUnit(4, IN)));

        }
        else {
            writeBlock("T" + toolFormat.format(tool.number), mFormat.format(6));
        }

        if (tool.comment) {
            writeComment(tool.comment);
        }
        var showToolZMin = false;
        if (showToolZMin) {
            if (is3D()) {
                var numberOfSections = getNumberOfSections();
                var zRange = currentSection.getGlobalZRange();
                var number = tool.number;
                for (var i = currentSection.getId() + 1; i < numberOfSections; ++i) {
                    var section = getSection(i);
                    if (section.getTool().number != number) {
                        break;
                    }
                    zRange.expandToRange(section.getGlobalZRange());
                }
                writeComment(localize("ZMIN") + "=" + zRange.getMinimum());
            }
        }

        if (getProperty("preloadTool")) {
            var nextTool = getNextTool(tool.number);
            if (nextTool) {
                writeBlock("T" + toolFormat.format(nextTool.number));
            } else {
                // preload first tool
                var section = getSection(0);
                var firstToolNumber = section.getTool().number;
                if (tool.number != firstToolNumber) {
                    writeBlock("T" + toolFormat.format(firstToolNumber));
                }
            }
        }
    }

    var sCode = Math.round(spindleSpeed);

    if (isProbeOperation()) {
        //Orient Spindle for probing accuracy
        writeBlock(mFormat.format(19));
    }
    else if (insertToolCall ||
        isFirstSection() ||
        (rpmFormat.areDifferent(sCode, sOutput.getCurrent())) ||
        (tool.clockwise != getPreviousSection().getTool().clockwise)) {
        // if (sCode < 1) {
        //   error(localize("Spindle speed out of range."));
        // }
        if (tapping && (sCode > maxTappingRPM)) {
            warning(localize("Spindle speed exceeds maximum tapping value."));
        } else if (sCode > maxRPM) {
            warning(localize("Spindle speed exceeds maximum value."));
        }

        var sCode = sCode;
        if (tapping && sCode > 750) {
            sCode += 0.2; // use high gear for tapping
        }
        if (tapping && getProperty("useRigidTapping")) {
            writeBlock(
                sOutput.format(sCode)
            );
        } else {
            writeBlock(
                sOutput.format(sCode), mFormat.format(tool.clockwise ? 3 : 4)
            );
            if (isFirstSection()) { // TAG: if RPM changes
                var seconds = 3 * 60 / spindleSpeed; // wait for 3 revolutions
                writeBlock(gFormat.format(4), "P" + milliFormat.format(seconds * 1000));

            }
        }
    }

    // wcs
    if (insertToolCall) { // force work offset when changing tool
        currentWorkOffset = undefined;
    }
    var workOffset = currentSection.workOffset;
    var wcsCode = "";
    if (workOffset == 0) {
        if (getProperty("onlyENumbers")) {
            warningOnce(localize("Work offset has not been specified. Using E1 as WCS."), WARNING_WORK_OFFSET);
        } else {
            warningOnce(localize("Work offset has not been specified. Using G54 as WCS."), WARNING_WORK_OFFSET);
        }
        workOffset = 1;
    }
    if (workOffset > 0) {
        if (getProperty("format") == 1) {
            if (workOffset != currentWorkOffset) {
                wcsCode = eFormat.format(workOffset);
                currentWorkOffset = workOffset;
            }
        } else {
            if (getProperty("onlyENumbers") || (workOffset > 6)) {
                if (workOffset > 24) {
                    error(localize("Work offset out of range."));
                }
                if (workOffset != currentWorkOffset) {
                    wcsCode = eFormat.format(workOffset);
                    currentWorkOffset = workOffset;
                }
            } else {
                if (workOffset != currentWorkOffset) {
                    wcsCode = gFormat.format(53 + workOffset); // G54->G59
                    currentWorkOffset = workOffset;
                }
            }
        }
    }

    forceXYZ();

    if (machineConfiguration.isMultiAxisConfiguration()) { // use 5-axis indexing for multi-axis mode
        // set working plane after datum shift

        var abc = new Vector(0, 0, 0);
        if (currentSection.isMultiAxis()) {
            forceWorkPlane();
            cancelTransformation();
        } else {
            abc = getWorkPlaneMachineABC(currentSection.workPlane);
        }
        setWorkPlane(abc);
    } else { // pure 3D
        var remaining = currentSection.workPlane;
        if (!isSameDirection(remaining.forward, new Vector(0, 0, 1))) {
            error(localize("Tool orientation is not supported."));
            return;
        }
        setRotation(remaining);
    }

    // set coolant after we have positioned at Z
    setCoolant(tool.coolant);

    forceAny();

    if (tapping && getProperty("useRigidTapping")) {
        writeBlock(gFormat.format(leftTapping ? 74.2 : 84.2));
    }

    var initialPosition = getFramePosition(currentSection.getInitialPosition());
    if (!retracted && !insertToolCall) {
        if (getCurrentPosition().z < initialPosition.z) {
            writeBlock(gMotionModal.format(0), wcsCode, zOutput.format(initialPosition.z));
            wcsCode = "";
        }
    }

    if (insertToolCall || retracted) {
        var lengthOffset = tool.lengthOffset;
        if (lengthOffset > 200) {
            error(localize("Length offset out of range."));
            return;
        }

        gMotionModal.reset();
        writeBlock(gPlaneModal.format(17));

        if (tapping && (getProperty("format") == 1)) {
            writeBlock(gAccDecModal.format(8));
        }

        if (!machineConfiguration.isHeadConfiguration()) {
            writeBlock(
                gAbsIncModal.format(90),
                gMotionModal.format(0), wcsCode, xOutput.format(initialPosition.x), yOutput.format(initialPosition.y)
            );
            if (getProperty("format") == 1) {
                writeBlock(gMotionModal.format(0), hFormat.format(lengthOffset), zOutput.format(initialPosition.z));
            } else {
                writeBlock(gMotionModal.format(0), gFormat.format(43), zOutput.format(initialPosition.z), hFormat.format(lengthOffset));
            }
        } else {
            if (getProperty("format") == 1) {
                writeBlock(
                    gAbsIncModal.format(90),
                    gMotionModal.format(0),
                    wcsCode,
                    hFormat.format(lengthOffset),
                    xOutput.format(initialPosition.x),
                    yOutput.format(initialPosition.y),
                    zOutput.format(initialPosition.z)
                );
            } else {
                writeBlock(
                    gAbsIncModal.format(90),
                    gMotionModal.format(0),
                    wcsCode,
                    gFormat.format(43), xOutput.format(initialPosition.x),
                    yOutput.format(initialPosition.y),
                    zOutput.format(initialPosition.z), hFormat.format(lengthOffset)
                );
            }
        }
    } else {
        var x = xOutput.format(initialPosition.x);
        var y = yOutput.format(initialPosition.y);
        if (x && y) {
            // axes are not synchronized
            writeBlock(gAbsIncModal.format(90), gMotionModal.format(1), wcsCode, x, y, feedOutput.format(highFeedrate));
        } else {
            writeBlock(gAbsIncModal.format(90), gMotionModal.format(0), wcsCode, x, y);
        }
    }

    /*
      if (getProperty("smoothingTolerance") > 0) {
        writeBlock(gFormat.format(187), "E" + xyzFormat.format(getProperty("smoothingTolerance")));
      }
    */
}

function onDwell(seconds) {
    if (seconds > 99999.999) {
        warning(localize("Dwelling time is out of range."));
    }
    seconds = clamp(0.001, seconds, 99999.999);
    writeBlock(gFeedModeModal.format(94), gFormat.format(4), "P" + milliFormat.format(seconds * 1000));
}

function onSpindleSpeed(spindleSpeed) {
    writeBlock(sOutput.format(spindleSpeed));
}

function onCycle() {
    writeBlock(gPlaneModal.format(17));
}

function getCommonCycle(x, y, z, r) {
    forceXYZ();
    return [xOutput.format(x), yOutput.format(y),
    zOutput.format(z),
    "R0" + rFormat.format(r)];
}

function onCyclePoint(x, y, z) {
    if (isProbeOperation()) {
        writeProbeCycle(x, y, z, cycle);
    }
    else {
        if (!isSameDirection(getRotation().forward, new Vector(0, 0, 1))) {
            expandCyclePoint(x, y, z);
            return;
        }
        if (isFirstCyclePoint()) {



            gRetractModal.reset(); // force G98 to avoid slow feed issue between canned cycles reported for some CNCs
            repositionToCycleClearance(cycle, x, y, z);
            writeBlock(gMotionModal.format(0)); // G01 can cause slow feeds between canned cycles    
            // return to initial Z which is clearance plane and set absolute mode

            var F = cycle.feedrate;
            var dwell = (cycle.dwell == 0) ? 0 : clamp(1, cycle.dwell * 1000, 99999999); // in milliseconds

            var leftTappingCode = getProperty("useRigidTapping") ? 74.1 : 74;
            var rightTappingCode = getProperty("useRigidTapping") ? 84.1 : 84;
            var sOut = Math.round(spindleSpeed);
            var tappingRPM = (sOut > 750) ? Math.round(sOut) + 0.2 : sOut;
            if (tapping && ((cycle.clearance - cycle.stock) < toPreciseUnit(0.39999, IN))) {
                warning(localize("The retract plane should be greater than ") + xyzFormat.format(toPreciseUnit(0.4, IN)) + localize(" when tapping."));
            }

            switch (cycleType) {
                case "drilling":
                    writeBlock(
                        gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(81),
                        getCommonCycle(x, y, z, cycle.retract),
                        feedOutput.format(F)
                    );
                    break;
                case "counter-boring":
                    if (dwell > 0) {
                        writeBlock(
                            gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(82),
                            getCommonCycle(x, y, z, cycle.retract),
                            "P" + milliFormat.format(dwell),
                            feedOutput.format(F)
                        );
                    } else {
                        writeBlock(
                            gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(81),
                            getCommonCycle(x, y, z, cycle.retract),
                            feedOutput.format(F)
                        );
                    }
                    break;
                case "chip-breaking":
                    if ((cycle.accumulatedDepth < cycle.depth) || (dwell > 0)) {
                        expandCyclePoint(x, y, z);
                    } else {
                        writeBlock(
                            gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(73),
                            getCommonCycle(x, y, z, cycle.retract),
                            (((cycle.incrementalDepthReduction > 0) ? "I" : "Q") + xyzFormat.format(cycle.incrementalDepth)),
                            conditional(cycle.incrementalDepthReduction > 0, "J" + xyzFormat.format(cycle.incrementalDepthReduction)),
                            conditional(cycle.incrementalDepthReduction > 0, "K" + xyzFormat.format(cycle.minimumIncrementalDepth)),
                            conditional(cycle.chipBreakDistance > 0, "P" + xyzFormat.format(cycle.chipBreakDistance)), // optional P value
                            feedOutput.format(F)
                        );
                    }
                    break;
                case "deep-drilling":
                    if (dwell > 0) {
                        expandCyclePoint(x, y, z);
                    } else {
                        writeBlock(
                            gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(83),
                            getCommonCycle(x, y, z, cycle.retract),
                            (((cycle.incrementalDepthReduction > 0) ? "I" : "Q") + xyzFormat.format(cycle.incrementalDepth)),
                            conditional(cycle.incrementalDepthReduction > 0, "J" + xyzFormat.format(cycle.incrementalDepthReduction)),
                            conditional(cycle.incrementalDepthReduction > 0, "K" + xyzFormat.format(cycle.minimumIncrementalDepth)),
                            feedOutput.format(F)
                        );
                    }
                    break;
                case "tapping":
                    if (getProperty("format") == 1) {
                        writeBlock(
                            gRetractModal.format(98), gAbsIncModal.format(90),
                            gCycleModal.format((tool.type == TOOL_TAP_LEFT_HAND) ? leftTappingCode : rightTappingCode),
                            getCommonCycle(x, y, z, cycle.retract),
                            "Q" + xyzFormat.format(tool.threadPitch),
                            "F" + feedFormat.format(tappingRPM)
                        );
                        feedOutput.reset();
                    } else {
                        if (!F) {
                            F = tool.getTappingFeedrate();
                        }
                        writeBlock(
                            gRetractModal.format(98), gAbsIncModal.format(90),
                            gCycleModal.format((tool.type == TOOL_TAP_LEFT_HAND) ? leftTappingCode : rightTappingCode),
                            getCommonCycle(x, y, z, cycle.retract),
                            conditional(getProperty("useRigidTapping"), sOutput.format(tappingRPM)),
                            tapFeedOutput.format(F)
                        );
                        feedOutput.reset();
                    }
                    break;
                case "left-tapping":
                    if (getProperty("format") == 1) {
                        writeBlock(
                            gRetractModal.format(98), gAbsIncModal.format(90),
                            gCycleModal.format(leftTappingCode),
                            getCommonCycle(x, y, z, cycle.retract),
                            "Q" + xyzFormat.format(tool.threadPitch),
                            "F" + feedFormat.format(tappingRPM)
                        );
                        feedOutput.reset();
                    } else {
                        if (!F) {
                            F = tool.getTappingFeedrate();
                        }
                        writeBlock(
                            gRetractModal.format(98), gAbsIncModal.format(90),
                            gCycleModal.format(leftTappingCode),
                            getCommonCycle(x, y, z, cycle.retract),
                            conditional(getProperty("useRigidTapping"), sOutput.format(tappingRPM)),
                            tapFeedOutput.format(F)
                        );
                        feedOutput.reset();
                    }
                    break;
                case "right-tapping":
                    if (getProperty("format") == 1) {
                        writeBlock(
                            gRetractModal.format(98), gAbsIncModal.format(90),
                            gCycleModal.format(rightTappingCode),
                            getCommonCycle(x, y, z, cycle.retract),
                            "Q" + xyzFormat.format(tool.threadPitch),
                            "F" + feedFormat.format(tappingRPM)
                        );
                        feedOutput.reset();
                    } else {
                        if (!F) {
                            F = tool.getTappingFeedrate();
                        }
                        writeBlock(
                            gRetractModal.format(98), gAbsIncModal.format(90),
                            gCycleModal.format(rightTappingCode),
                            getCommonCycle(x, y, z, cycle.retract),
                            conditional(getProperty("useRigidTapping"), sOutput.format(tappingRPM)),
                            tapFeedOutput.format(F)
                        );
                        feedOutput.reset();
                    }
                    break;
                case "fine-boring":
                    // shift along Y+
                    writeBlock(
                        gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(76),
                        getCommonCycle(x, y, z, cycle.retract),
                        "P" + milliFormat.format(dwell),
                        "Q" + xyzFormat.format(cycle.shift),
                        feedOutput.format(F)
                    );
                    break;
                case "back-boring":
                    expandCyclePoint(x, y, z);
                    break;
                case "reaming":
                    if (dwell > 0) {
                        writeBlock(
                            gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(89),
                            getCommonCycle(x, y, z, cycle.retract),
                            "P" + milliFormat.format(dwell),
                            feedOutput.format(F)
                        );
                    } else {
                        writeBlock(
                            gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(85),
                            getCommonCycle(x, y, z, cycle.retract),
                            feedOutput.format(F)
                        );
                    }
                    break;
                case "stop-boring":
                    if (dwell > 0) {
                        expandCyclePoint(x, y, z);
                    } else {
                        // no stop orientation
                        writeBlock(
                            gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(86),
                            getCommonCycle(x, y, z, cycle.retract),
                            feedOutput.format(F)
                        );
                    }
                    break;
                case "manual-boring":
                    expandCyclePoint(x, y, z);
                    break;
                case "boring":
                    if (dwell > 0) {
                        writeBlock(
                            gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(89),
                            getCommonCycle(x, y, z, cycle.retract),
                            "P" + milliFormat.format(dwell),
                            feedOutput.format(F)
                        );
                    } else {
                        writeBlock(
                            gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(86),
                            getCommonCycle(x, y, z, cycle.retract),
                            feedOutput.format(F)
                        );
                    }
                    break;

                default:
                    expandCyclePoint(x, y, z);
            }
        } else {
            if (cycleExpanded) {
                expandCyclePoint(x, y, z);
            } else {
                writeBlock(xOutput.format(x), yOutput.format(y));
            }
        }
    }
}

//PROBING SECTION 
//BITS TO CHIPS LLC 2022

var currentVolatileZ;
var probeContinue = 1;
var probeOperationWorkOffset = 1;
var probeOutputWorkOffset = 1;
var probeMeasureFeed = 15;
var probeLinkFeed = 50;
var probeOverrideWorkOffset = false;
var probeHasPositionTolerance = false;
var probeSizeTolerance = 0;

function onParameter(name, value) {
    if (name == "operation:probeWorkOffset") {
        probeOperationWorkOffset = (value > 0) ? value : 1;
    }
    if (name == "operation:probe_overrideWorkOffset") {
        probeOverrideWorkOffset = Boolean(value);
    }
    if (name == "probe-output-work-offset") {
        probeOutputWorkOffset = (value > 0) ? value : 1;
    }
    if (name == "operation:tool_feedProbeMeasure") {
        probeMeasureFeed = (value > 0) ? value : 15;
    }
    if (name == "tool_feedProbeLink") {
        probeOutputWorkOffset = (value > 0) ? value : 50;
    }
    if (name == "tolerancePosition") {
        probePositionTolerance = value;
    }
    if (name == "toleranceSize") {
        probeSizeTolerance = value;
    }
}

/** Convert approach to sign. */
function approach(value) {
    validate((value == "positive") || (value == "negative"), "Invalid approach.");
    return (value == "positive") ? 1 : -1;
}

function protectedProbeMove(_cycle, x, y, z) {
    var _x = xOutput.format(x);
    var _y = yOutput.format(y);
    var _z = zOutput.format(z);
    if (_z && z >= currentVolatileZ) {
        writeBlock(gFormat.format(31), _z, feedOutput.format(probeLinkFeed)); // protected positioning move
        currentVolatileZ = z;
    }
    if (_x || _y) {
        writeBlock(gFormat.format(31), _x, _y, feedOutput.format(probeLinkFeed)); // protected positioning move
    }
    if (_z && z < currentVolatileZ) {
        writeBlock(gFormat.format(31), _z, feedOutput.format(probeLinkFeed)); // protected positioning move
        currentVolatileZ = z;
    }
}

function writeProbeCycle(x, y, z, cycle) {
    if (!isSameDirection(currentSection.workPlane.forward, new Vector(0, 0, 1))) {
        if (!allowIndexingWCSProbing && currentSection.strategy == "probe") {
            error(localize("Updating WCS / work offset using probing is only supported by the CNC in the WCS frame."));
            return;
        } else if (getProperty("useDWO")) {
            error(localize("Your machine does not support the selected probing operation with DWO enabled."));
            return;
        }
    }

    //cycles are going to move around independent of where fusion thinks Z is.
    currentVolatileZ = getCurrentPosition().z;

    writeBlock(gMotionModal.format(1));
    if (probeOverrideWorkOffset) {
        writeComment(
            cycleType +
            " Working Offset: " + probeOperationWorkOffset
            + " Updating offset: " + probeOutputWorkOffset
        );
    }
    else {
        writeComment(cycleType);
    }

    var linkingZHeight = z - cycle.depth;

    if (cycleType.split("island").length > 1) {
        linkingZHeight = z;
    }

    storeCurrentFixtureOffsetPosition();

    switch (cycleType) {
        //PROBING
        //======================================================================================
        case "probing-x":

            //probe diameter already factored into probe clearance for these cycles
            var probeLateralMove = approach(cycle.approach1) * (cycle.probeClearance + cycle.probeOvertravel);
            var expectedProbeHit = x + approach(cycle.approach1) * (cycle.probeClearance);
            protectedProbeMove(cycle, x, y, linkingZHeight);
            probeX(cycle, x, y, z, probeLateralMove, expectedProbeHit);
            break;
        //======================================================================================
        case "probing-y":

            //probe diameter already factored into probe clearance for these cycles
            var probeLateralMove = approach(cycle.approach1) * (cycle.probeClearance + cycle.probeOvertravel);
            var expectedProbeHit = y + approach(cycle.approach1) * (cycle.probeClearance);
            protectedProbeMove(cycle, x, y, linkingZHeight);
            probeY(cycle, x, y, z, probeLateralMove, expectedProbeHit)
            break;
        //======================================================================================
        case "probing-z":
            var expectedSurfaceZ = z - cycle.depth;
            writeComment(
                cycleType
                + " centered at X" + xyzFormat.format(x)
                + " Y" + xyzFormat.format(y)
            );
            writeComment(
                "Working Offset: " + probeOperationWorkOffset
                + " Updating offset: " + probeOutputWorkOffset
            );
            writeComment(
                "Approach: " + xyzFormat.format(cycle.probeClearance)
                + " Overtravel: " + xyzFormat.format(cycle.probeOvertravel)
                + " Expected Surface Z: " + xyzFormat.format(expectedSurfaceZ)
            );


            protectedProbeMove(cycle, x, y, Math.min(expectedSurfaceZ + cycle.probeClearance, cycle.retract));
            //XZ Probe = G18 Plane
            writeBlock(gPlaneModal.format(18));
            writeBlock(
                "L9101 R1+1.",
                "X" + xyzFormat.format(x),
                "Z" + xyzFormat.format(expectedSurfaceZ - cycle.probeOvertravel),
                "F" + feedFormat.format(cycle.feedrate),
                "P1 P2" //P1 and P2 so we can check with L9101 R1+4
            );

            //have to do this to check for probe hit with one point easily
            writeProbeTolerance(expectedSurfaceZ, "PZ2");
            writeBlock("L9101 R1+4.");
            writeBlock(
                "#FZ" + probeOutputWorkOffset
                + "=PZ2+FZ" + probeOperationWorkOffset
                + "-" + xyzFormat.format(expectedSurfaceZ)
            );
            break;
        //======================================================================================
        case "probing-xy-rectangular-hole":
        case "probing-xy-circular-hole":

            //circular probe won't have a width 2, use width 1 (x)
            var xWidth = cycle.width1;
            var yWidth = (cycle.width2 > 0) ? cycle.width2 : xWidth;

            writeComment("Centered at X" + xyzFormat.format(x)
                + " Y" + xyzFormat.format(y));
            writeComment(
                "Working Offset: " + probeOperationWorkOffset
                + " Updating offset: " + probeOutputWorkOffset);
            writeComment(
                "X Width: " + xyzFormat.format(xWidth)
                + " Y Width: " + xyzFormat.format(yWidth)
                + " Approach: " + xyzFormat.format(cycle.probeClearance)
                + " Overtravel: " + xyzFormat.format(cycle.probeOvertravel));

            probeXChannel(cycle, x, y, z, xwidth, linkingZHeight);
            probeYChannel(cycle, x, y, z, yWidth, linkingZHeight);
            break;
        //======================================================================================
        case "probing-xy-rectangular-boss":
        case "probing-xy-circular-boss":

            //circular probe won't have a width 2, use width 1 (x)
            var xWidth = cycle.width1;
            var yWidth = (cycle.width2 > 0) ? cycle.width2 : xWidth;

            writeComment(
                "Centered at X" + xyzFormat.format(x)
                + " Y" + xyzFormat.format(y));
            writeComment(
                "Working Offset: " + probeOperationWorkOffset
                + " Updating offset: " + probeOutputWorkOffset);
            writeComment(
                "X Width: " + xyzFormat.format(xWidth)
                + " Y Width: " + xyzFormat.format(yWidth)
                + " Approach: " + xyzFormat.format(cycle.probeClearance)
                + " Overtravel: " + xyzFormat.format(cycle.probeOvertravel));

            probeXWall(cycle, x, y, z, xWidth);
            probeYWall(cycle, x, y, z, yWidth);
            break;
        //======================================================================================
        case "probing-xy-outer-corner":

            var probeLateralMove = cycle.probeClearance + (tool.diameter / 2);
            var expectedProbeHitX = x + approach(cycle.approach1) * (probeLateralMove - (tool.diameter / 2));
            var expectedProbeHitY = y + approach(cycle.approach2) * (probeLateralMove - (tool.diameter / 2));

            writeComment(
                "X:" + xyzFormat.format(expectedProbeHitX)
                + " Y:" + xyzFormat.format(expectedProbeHitY));
            writeComment(
                "Working Offset: " + probeOperationWorkOffset
                + " Updating offset: " + probeOutputWorkOffset);
            writeComment(
                " Approach: " + xyzFormat.format(cycle.probeClearance)
                + " Overtravel: " + xyzFormat.format(cycle.probeOvertravel));

            protectedProbeMove(cycle, x, y, z - cycle.depth);
            //Y probe first
            var probeYStartX = x + 2 * approach(cycle.approach1) * probeLateralMove;
            protectedProbeMove(cycle, probeYStartX, y, z - cycle.depth);
            probeY(cycle, probeYStartX, y, approach(cycle.approach2) * (probeLateralMove + cycle.probeOvertravel), expectedProbeHitY);
            //reset
            protectedProbeMove(cycle, x, y, z - cycle.depth);
            //start x probe
            var probeXStartY = y + 2 * approach(cycle.approach2) * probeLateralMove;
            protectedProbeMove(cycle, x, probeXStartY, z - cycle.depth);
            probeX(cycle, x, probeXStartY, approach(cycle.approach1) * (probeLateralMove + cycle.probeOvertravel), expectedProbeHitX);
            break;
        //======================================================================================
        case "probing-xy-inner-corner":

            var probeLateralMove = cycle.probeClearance + (tool.diameter / 2);
            var expectedProbeHitX = x + approach(cycle.approach1) * (probeLateralMove - (tool.diameter / 2));
            var expectedProbeHitY = y + approach(cycle.approach2) * (probeLateralMove - (tool.diameter / 2));

            writeComment(
                "X:" + xyzFormat.format(expectedProbeHitX)
                + " Y:" + xyzFormat.format(expectedProbeHitY));
            writeComment(
                "Working Offset: " + probeOperationWorkOffset
                + " Updating offset: " + probeOutputWorkOffset);
            writeComment(
                + " Approach: " + xyzFormat.format(cycle.probeClearance)
                + " Overtravel: " + xyzFormat.format(cycle.probeOvertravel));

            protectedProbeMove(cycle, x, y, z - cycle.depth);
            //Y probe first
            probeY(cycle, x, y, approach(cycle.approach2) * (probeLateralMove + cycle.probeOvertravel), expectedProbeHitY);
            probeX(cycle, x, y, approach(cycle.approach1) * (probeLateralMove + cycle.probeOvertravel), expectedProbeHitX);
            break;
        //======================================================================================
        case "probing-x-wall":
            var width = cycle.width1;

            writeComment(
                "Centered at X" + xyzFormat.format(x)
                + " Y" + xyzFormat.format(y));
            writeComment(
                "Working Offset: " + probeOperationWorkOffset
                + " Updating offset: " + probeOutputWorkOffset);
            writeComment(
                "X Width: " + xyzFormat.format(width)
                + " Approach: " + xyzFormat.format(cycle.probeClearance)
                + " Overtravel: " + xyzFormat.format(cycle.probeOvertravel));

            probeXWall(cycle, x, y, z, width);
            break;
        //======================================================================================
        case "probing-y-wall":
            var width = cycle.width1;

            writeComment(
                "Centered at X" + xyzFormat.format(x)
                + " Y" + xyzFormat.format(y));
            writeComment(
                "Working Offset: " + probeOperationWorkOffset
                + " Updating offset: " + probeOutputWorkOffset);
            writeComment(
                "Y Width: " + xyzFormat.format(width)
                + " Approach: " + xyzFormat.format(cycle.probeClearance)
                + " Overtravel: " + xyzFormat.format(cycle.probeOvertravel));

            probeYWall(cycle, x, y, z, width);
            break;
        //======================================================================================
        case "probing-x-channel":
        case "probing-x-channel-with-island":
            var width = cycle.width1;

            writeComment(
                "Centered at X" + xyzFormat.format(x)
                + " Y" + xyzFormat.format(y));
            writeComment(
                "Working Offset: " + probeOperationWorkOffset
                + " Updating offset: " + probeOutputWorkOffset);
            writeComment(
                "X Width: " + xyzFormat.format(width)
                + " Approach: " + xyzFormat.format(cycle.probeClearance)
                + " Overtravel: " + xyzFormat.format(cycle.probeOvertravel));

            probeXChannel(cycle, x, y, z, width, linkingZHeight);
            break;
        //======================================================================================
        case "probing-y-channel":
        case "probing-y-channel-with-island":
            var width = cycle.width1;

            writeComment(
                "Centered at X" + xyzFormat.format(x)
                + " Y" + xyzFormat.format(y));
            writeComment(
                "Working Offset: " + probeOperationWorkOffset
                + " Updating offset: " + probeOutputWorkOffset);
            writeComment(
                "Y Width: " + xyzFormat.format(width)
                + " Approach: " + xyzFormat.format(cycle.probeClearance)
                + " Overtravel: " + xyzFormat.format(cycle.probeOvertravel));

            probeYChannel(cycle, x, y, z, width, linkingZHeight);
            break;
        //======================================================================================
        case "probing-xy-circular-partial-hole":
        case "probing-xy-circular-hole-with-island":
            var width = cycle.width1;
            var approachRadius = ((width - tool.diameter) / 2) - cycle.probeClearance;
            var probeRadius = (width / 2) + cycle.probeOvertravel;
            var probeOriginVector = new Vector(x, y, z);
            var aApproach = Vector.sum(probeOriginVector, Vector.getBySpherical(toRad(cycle.partialCircleAngleA), toRad(90), approachRadius));
            var aProbe = Vector.sum(probeOriginVector, Vector.getBySpherical(toRad(cycle.partialCircleAngleA), toRad(90), probeRadius));
            var bApproach = Vector.sum(probeOriginVector, Vector.getBySpherical(toRad(cycle.partialCircleAngleB), toRad(90), approachRadius));
            var bProbe = Vector.sum(probeOriginVector, Vector.getBySpherical(toRad(cycle.partialCircleAngleB), toRad(90), probeRadius));
            var cApproach = Vector.sum(probeOriginVector, Vector.getBySpherical(toRad(cycle.partialCircleAngleC), toRad(90), approachRadius));
            var cProbe = Vector.sum(probeOriginVector, Vector.getBySpherical(toRad(cycle.partialCircleAngleC), toRad(90), probeRadius));

            writeComment(
                "Centered at X" + xyzFormat.format(x)
                + " Y" + xyzFormat.format(y));
            writeComment(
                "Working Offset: " + probeOperationWorkOffset
                + " Updating offset: " + probeOutputWorkOffset);
            writeComment(
                "Angle A: " + xyzFormat.format(cycle.partialCircleAngleA)
                + " Angle B: " + xyzFormat.format(cycle.partialCircleAngleB)
                + " Angle C: " + xyzFormat.format(cycle.partialCircleAngleC));
            writeComment(
                "Approach: " + xyzFormat.format(cycle.probeClearance)
                + " Overtravel: " + xyzFormat.format(cycle.probeOvertravel));

            writeComment("A Angle Probe");
            protectedProbeMove(cycle, x, y, linkingZHeight);
            protectedProbeMove(cycle, aApproach.getX(), aApproach.getY(), z - cycle.depth);
            writeBlock(
                "L9101 R1+1.",
                "X" + xyzFormat.format(aProbe.getX()),
                "Y" + xyzFormat.format(aProbe.getY()),
                "F" + feedFormat.format(cycle.feedrate),
                "P1"
            );

            writeComment("B Angle Probe");
            protectedProbeMove(cycle, x, y, linkingZHeight);
            protectedProbeMove(cycle, bApproach.getX(), bApproach.getY(), z - cycle.depth);
            writeBlock(
                "L9101 R1+1.",
                "X" + xyzFormat.format(bProbe.getX()),
                "Y" + xyzFormat.format(bProbe.getY()),
                "F" + feedFormat.format(cycle.feedrate),
                "P2"
            );

            writeComment("C Angle Probe");
            protectedProbeMove(cycle, x, y, linkingZHeight);
            protectedProbeMove(cycle, cApproach.getX(), cApproach.getY(), z - cycle.depth);
            writeBlock(
                "L9101 R1+1.",
                "X" + xyzFormat.format(cProbe.getX()),
                "Y" + xyzFormat.format(cProbe.getY()),
                "F" + feedFormat.format(cycle.feedrate),
                "P3"
            );
            protectedProbeMove(cycle, x, y, linkingZHeight);

            writeProbeDiameterTolerance(width, "R3", tool.diameter);
            //Calculate Center
            writeBlock("L9101 R1+2.");
            writeProbePositionTolerance(x, "R1", 0);
            writeProbePositionTolerance(y, "R2", 0);
            //Store center
            writeBlock(
                "#FX" + probeOutputWorkOffset
                + "=R1+FX" + probeOperationWorkOffset
                + "-" + xyzFormat.format(x));
            writeBlock(
                "#FY" + probeOutputWorkOffset
                + "=R2+FY" + probeOperationWorkOffset
                + "-" + xyzFormat.format(y));
            break;
        //======================================================================================
        case "probing-x-plane-angle":
        var nomAngle = cycle.nominalAngle != undefined ? cycle.nominalAngle : 90
        var probeLateralMove = approach(cycle.approach1) * (cycle.probeClearance + cycle.probeOvertravel);
        var approachRadius = ((width - tool.diameter) / 2) - cycle.probeClearance;
        var probeRadius = (width / 2) + cycle.probeOvertravel;
        var probeOriginVector = new Vector(x, y, z);
        var probeAttackVector = new Vector(probeLateralMove, 0, 0);
        var aApproach = Vector.sum(probeOriginVector, Vector.getBySpherical(toRad(nomAngle), toRad(90), cycle.probeSpacing/s));
        var aProbe = Vector.sum(aApproach, probeAttackVector);
        var bApproach = aApproach.getNegated();
        var bProbe = Vector.sum(aApproach, probeAttackVector);
        

        writeComment(nomAngle);

        break;


        //END SUPPORTED PROBING ROUTINES
    }
    protectedProbeMove(cycle, x, y, cycle.retract);
    writeFixtureOffsetPosition("FINISHED " + cycleType);
}

function probeX(_cycle, x, y, probeLateralMove, expectedProbeHit) {
    //XY Probe = G17 Plane
    writeBlock(gPlaneModal.format(17));
    writeBlock(
        "L9101 R1+1.",
        "X" + xyzFormat.format(x + probeLateralMove),
        "Y" + xyzFormat.format(y),
        "F" + feedFormat.format(cycle.feedrate),
        "P1 P2" //P1 and P2 so we can check with L9101 R1+4
    );
    writeProbePositionTolerance(expectedProbeHit, "PX2", approach(cycle.approach1) * tool.diameter / 2);
    writeBlock("L9101 R1+4.");
    //have to do this to check for probe hit with one point easily
    writeBlock(
        "#FX" + probeOutputWorkOffset
        + "=PX2+FX" + probeOperationWorkOffset
        + "+" + xyzFormat.format(-expectedProbeHit)
    );
}

function probeY(_cycle, x, y, probeLateralMove, expectedProbeHit) {
    //XY Probe = G17 Plane
    writeBlock(gPlaneModal.format(17));
    writeBlock(
        "L9101 R1+1.",
        "X" + xyzFormat.format(x),
        "Y" + xyzFormat.format(y + probeLateralMove),
        "F" + feedFormat.format(cycle.feedrate),
        "P1 P2" //P1 and P2 so we can check with L9101 R1+4
    );
    writeProbePositionTolerance(expectedProbeHit, "PY2", approach(cycle.approach1) * tool.diameter / 2);
    //have to do this to check for probe hit with one point easily
    writeBlock("L9101 R1+4.");
    writeBlock(
        "#FY" + probeOutputWorkOffset
        + "=PY2+FY" + probeOperationWorkOffset
        + "+" + xyzFormat.format(-expectedProbeHit)
    );
}

function probeXWall(_cycle, x, y, z, width) {
    var lateralMove = (width / 2) + (cycle.probeClearance + tool.diameter / 2);
    var probeLateralMove = (width / 2) - cycle.probeOvertravel;

    //XY Probe = G17 Plane
    writeBlock(gPlaneModal.format(17));

    writeComment("X+ Probe");
    protectedProbeMove(cycle, x, y, linkingZHeight);
    protectedProbeMove(cycle, x + lateralMove, y, z - cycle.depth);
    writeBlock(
        "L9101 R1+1.",
        "X" + xyzFormat.format(x + probeLateralMove),
        "Y" + xyzFormat.format(y),
        "F" + feedFormat.format(cycle.feedrate),
        "P1"
    );

    writeComment("X- Probe");
    protectedProbeMove(cycle, x - lateralMove, y, linkingZHeight);
    writeBlock(
        "L9101 R1+1.",
        "X" + xyzFormat.format(x - probeLateralMove),
        "Y" + xyzFormat.format(y),
        "F" + feedFormat.format(cycle.feedrate),
        "P2"
    );
    protectedProbeMove(cycle, x, y, zlinkingZHeight);

    writeProbeSizeTolerance(width, "X", -tool.diameter)
    //Calculate Center X
    writeBlock("L9101 R1+4.");
    writeProbePositionTolerance(x, "R1", 0);
    //Store X center
    writeBlock(
        "#FX" + probeOutputWorkOffset
        + "=R1+FX" + probeOperationWorkOffset
        + "-" + xyzFormat.format(x));
}

function probeYWall(_cycle, x, y, z, width) {
    var lateralMove = (width / 2) + (cycle.probeClearance + tool.diameter / 2);
    var probeLateralMove = (width / 2) - cycle.probeOvertravel;
    //XY Probe = G17 Plane
    writeBlock(gPlaneModal.format(17));

    writeComment("Y+ Probe");
    protectedProbeMove(cycle, x, y, linkingZHeight);
    protectedProbeMove(cycle, x, y + lateralMove, z - cycle.depth);
    writeBlock(
        "L9101 R1+1.",
        "X" + xyzFormat.format(x),
        "Y" + xyzFormat.format(y + probeLateralMove),
        "F" + feedFormat.format(cycle.feedrate),
        "P1"
    );

    writeComment("Y- Probe");
    protectedProbeMove(cycle, x, y - lateralMove, linkingZHeight);
    writeBlock(
        "L9101 R1+1.",
        "X" + xyzFormat.format(x),
        "Y" + xyzFormat.format(y - probeLateralMove),
        "F" + feedFormat.format(cycle.feedrate),
        "P2"
    );
    protectedProbeMove(cycle, x, y, linkingZHeight);

    writeProbeSizeTolerance(width, "Y", -tool.diameter)
    //Calculate Center Y
    writeBlock("L9101 R1+4.");
    //Store Y Center
    writeProbePositionTolerance(y, "R2", 0);

    writeBlock(
        "#FY" + probeOutputWorkOffset
        + "=R2+FY" + probeOperationWorkOffset
        + "-" + xyzFormat.format(y));
}

function probeXChannel(_cycle, x, y, z, width, linkingZHeight) {
    var lateralMove = (width / 2) - (cycle.probeClearance + tool.diameter / 2);
    var probeLateralMove = (width / 2) + cycle.probeOvertravel;

    //XY Probe = G17 Plane
    writeBlock(gPlaneModal.format(17));

    writeComment("X+ Probe");
    protectedProbeMove(cycle, x, y, linkingZHeight);
    protectedProbeMove(cycle, x + lateralMove, y, z - cycle.depth);
    writeBlock(
        "L9101 R1+1.",
        "X" + xyzFormat.format(x - probeLateralMove),
        "Y" + xyzFormat.format(y),
        "F" + feedFormat.format(cycle.feedrate),
        "P1"
    );

    writeComment("X- Probe");
    protectedProbeMove(cycle, x - lateralMove, y, linkingZHeight);
    protectedProbeMove(cycle, x - lateralMove, y, z - cycle.depth);
    writeBlock(
        "L9101 R1+1.",
        "X" + xyzFormat.format(x + probeLateralMove),
        "Y" + xyzFormat.format(y),
        "F" + feedFormat.format(cycle.feedrate),
        "P2"
    );

    protectedProbeMove(cycle, x, y, linkingZHeight);

    writeProbeSizeTolerance(width - tool.diameter, "X", tool.diameter);
    //Calculate Center X
    writeBlock("L9101 R1+4.");
    writeProbePositionTolerance(x, "R1", 0);
    //Store X center
    writeBlock(
        "#FX" + probeOutputWorkOffset
        + "=R1+FX" + probeOperationWorkOffset
        + "-" + xyzFormat.format(x));
}

function probeYChannel(_cycle, x, y, z, width, linkingZHeight) {
    var lateralMove = (width / 2) - (cycle.probeClearance + tool.diameter / 2);
    var probeLateralMove = (width / 2) + cycle.probeOvertravel;
    //XY Probe = G17 Plane
    writeBlock(gPlaneModal.format(17));

    writeComment("Y+ Probe");
    protectedProbeMove(cycle, x, y, linkingZHeight);
    protectedProbeMove(cycle, x, y + lateralMove, z - cycle.depth);
    writeBlock(
        "L9101 R1+1.",
        "X" + xyzFormat.format(x),
        "Y" + xyzFormat.format(y + probeLateralMove),
        "F" + feedFormat.format(cycle.feedrate),
        "P1"
    );

    writeComment("Y- Probe");
    protectedProbeMove(cycle, x, y - lateralMove, linkingZHeight);
    protectedProbeMove(cycle, x, y - lateralMove, z - cycle.depth);
    writeBlock(
        "L9101 R1+1.",
        "X" + xyzFormat.format(x),
        "Y" + xyzFormat.format(y - probeLateralMove),
        "F" + feedFormat.format(cycle.feedrate),
        "P2"
    );
    protectedProbeMove(cycle, x, y, linkingZHeight);

    writeProbeSizeTolerance(width, "Y", tool.diameter);
    //Calculate Center Y
    writeBlock("L9101 R1+4.");
    writeProbePositionTolerance(x, "R2", 0);
    //Store Y Center

    writeBlock(
        "#FY" + probeOutputWorkOffset
        + "=R2+FY" + probeOperationWorkOffset
        + "-" + xyzFormat.format(y));
}

function storeCurrentFixtureOffsetPosition() {
    if (printProbeResults()) {
        writeBlock("#V10=FX" + probeOutputWorkOffset);
        writeBlock("#V11=FY" + probeOutputWorkOffset);
        writeBlock("#V12=FZ" + probeOutputWorkOffset);
        writeBlock("#V13=FA" + probeOutputWorkOffset);
        writeBlock("#V14=FB" + probeOutputWorkOffset);
    }
}

function writeFixtureOffsetPosition(message) {
    if (printProbeResults()) {
        writeBlock("#PRINT \" \"");
        writeBlock("#PRINT \"" + message + "\"");
        writeBlock("#PRINT \"OLD E" + probeOutputWorkOffset
            + " X:\",V10"
            + ",\" Y:\",V11"
            + ",\" Z:\",V12"
            + ",\" A:\",V13"
            + ",\" B:\",V14");
        writeBlock("#PRINT \"NEW E" + probeOutputWorkOffset
            + " X:\",FX" + probeOutputWorkOffset
            + ",\" Y:\",FY" + probeOutputWorkOffset
            + ",\" Z:\",FZ" + probeOutputWorkOffset
            + ",\" A:\",FA" + probeOutputWorkOffset
            + ",\" B:\",FB" + probeOutputWorkOffset);
        writeBlock("#INPUT V1");
    }
}

function writeProbePositionTolerance(expectedProbeHit, point, probeTipCompensation) {
    //expected probe hit doesn't include the tip diameter
    //point "PX1", "PY2", etc
    //probe tip radius, negative or positive depending on approach, zero if it's a center
    if (cycle.outOfPositionAction == "stop-message") {
        //actual corrected
        writeComment("Position Tolerance");
        writeBlock("#V1 = " + point + " + " + xyzFormat.format(probeTipCompensation));
        //expected corrected
        writeBlock("#V2 = " + xyzFormat.format(expectedProbeHit + probeTipCompensation));
        //min
        writeBlock("#V3 = V2 - " + xyzFormat.format(probePositionTolerance));
        //max
        writeBlock("#V4 = V2 + " + xyzFormat.format(probePositionTolerance));
        //position check logic

        writeBlock("#IF V3 LT V1 AND V1 LT V4 THEN GOTO :CONTINUE" + probeContinue);
        writeBlock("#PRINT \" \"");
        writeBlock("#PRINT \"==================================================\"");
        writeBlock("#PRINT \"ERROR: PROBE OUT OF POSITION TOLERANCE RANGE\"");
        writeBlock("#PRINT \"EXPECTED POSITION \",V2,\"+- " + xyzFormat.format(probePositionTolerance) + "\"");
        writeBlock("#PRINT \"ACTUAL POSITION\",V1");
        writeBlock("#PRINT \"PRESS ENTER TO CONTINUE ANYWAY OR MANUAL TO EXIT\"");
        writeBlock("#PRINT \"==================================================\"");
        writeBlock("#INPUT V2");
        writeBlock("#:CONTINUE" + probeContinue++);
    }
}

function writeProbeSizeTolerance(expectedSize, axis, probeTipCompensation) {
    //expected size doesn't include the tip diameter
    //axis is just "X" or "Y"
    //probe tip diameter, negative for bosses, positive for bores
    if (cycle.wrongSizeAction == "stop-message") {

        writeComment("Size Tolerance");
        //actual corrected
        writeBlock("#V1 = P" + axis + "2 - P" + axis + "1 + " + xyzFormat.format(probeTipCompensation));
        //expected
        writeBlock("#V2 = " + xyzFormat.format(expectedSize))
        //min
        writeBlock("#V3 = V2 - " + xyzFormat.format(probeSizeTolerance));
        //max
        writeBlock("#V4 = V2 + " + xyzFormat.format(probeSizeTolerance));
        //Size check logic
        writeBlock("#IF V3 LT V1 AND V1 LT V4 THEN GOTO :CONTINUE" + probeContinue);
        writeBlock("#PRINT \" \"");
        writeBlock("#PRINT \"==================================================\"");
        writeBlock("#PRINT \"ERROR: PROBE OUT OF SIZE TOLERANCE RANGE\"");
        writeBlock("#PRINT \"EXPECTED SIZE \",V2,\" +- " + xyzFormat.format(probeSizeTolerance) + "\"");
        writeBlock("#PRINT \"ACTUAL SIZE \",V1");
        writeBlock("#PRINT \"PRESS ENTER TO CONTINUE ANYWAY OR MANUAL TO EXIT\"");
        writeBlock("#PRINT \"==================================================\"");
        writeBlock("#INPUT V5");
        writeBlock("#:CONTINUE" + probeContinue++);
    }
}

function writeProbeDiameterTolerance(expectedDiameter, rWord, probeTipCompensation) {
    //expected radius doesn't include the tip diameter
    //rWord = R1, R2, R3 (usually R3)
    //probe tip diameter, negative for bosses, positive for bores
    if (cycle.wrongSizeAction == "stop-message") {

        writeComment("Size Tolerance");
        //actual corrected
        writeBlock("#V1 = 2*" + rWord + "+" + xyzFormat.format(probeTipCompensation));
        //expected
        writeBlock("#V2 = " + xyzFormat.format(expectedDiameter))
        //min
        writeBlock("#V3 = V2 - " + xyzFormat.format(probeSizeTolerance));
        //max
        writeBlock("#V4 = V2 + " + xyzFormat.format(probeSizeTolerance));
        //Size check logic
        writeBlock("#IF V3 LT V1 AND V1 LT V4 THEN GOTO :CONTINUE" + probeContinue);
        writeBlock("#PRINT \" \"");
        writeBlock("#PRINT \"==================================================\"");
        writeBlock("#PRINT \"ERROR: PROBE OUT OF SIZE TOLERANCE RANGE\"");
        writeBlock("#PRINT \"EXPECTED SIZE \",V2,\" +- " + xyzFormat.format(probeSizeTolerance) + "\"");
        writeBlock("#PRINT \"ACTUAL SIZE \",V1");
        writeBlock("#PRINT \"PRESS ENTER TO CONTINUE ANYWAY OR MANUAL TO EXIT\"");
        writeBlock("#PRINT \"==================================================\"");
        writeBlock("#INPUT V5");
        writeBlock("#:CONTINUE" + probeContinue++);
    }
}

function printProbeResults() {
    return currentSection.getParameter("printResults", 0) == 1;
}

function onCycleEnd() {
    if (!cycleExpanded) {
        writeBlock(gCycleModal.format(80));
        zOutput.reset();
    }
}

var pendingRadiusCompensation = -1;

function onRadiusCompensation() {
    pendingRadiusCompensation = radiusCompensation;
}

function onRapid(_x, _y, _z) {
    var x = xOutput.format(_x);
    var y = yOutput.format(_y);
    var z = zOutput.format(_z);
    if (x || y || z) {
        if (pendingRadiusCompensation >= 0) {
            error(localize("Radius compensation mode cannot be changed at rapid traversal."));
        }
        if (((x ? 1 : 0) + (y ? 1 : 0) + (z ? 1 : 0)) > 1) {
            // axes are not synchronized
            writeBlock(gMotionModal.format(1), x, y, z, feedOutput.format(highFeedrate));
        } else {
            writeBlock(gMotionModal.format(0), x, y, z);
            feedOutput.reset();
        }
    }
}

function onLinear(_x, _y, _z, feed) {
    if (pendingRadiusCompensation >= 0) {
        // ensure that we end at desired position when compensation is turned off
        xOutput.reset();
        yOutput.reset();
    }
    var x = xOutput.format(_x);
    var y = yOutput.format(_y);
    var z = zOutput.format(_z);
    var f = feedOutput.format(feed);
    if (x || y || z) {
        if (pendingRadiusCompensation >= 0) {
            pendingRadiusCompensation = -1;
            var d = tool.diameterOffset;
            if (d > 200) {
                warning(localize("The diameter offset exceeds the maximum value."));
            }
            writeBlock(gPlaneModal.format(17));
            switch (radiusCompensation) {
                case RADIUS_COMPENSATION_LEFT:
                    dOutput.reset();
                    writeBlock(gFeedModeModal.format(94), gMotionModal.format(1), gFormat.format(41), dOutput.format(d), x, y, z, f);
                    break;
                case RADIUS_COMPENSATION_RIGHT:
                    dOutput.reset();
                    writeBlock(gFeedModeModal.format(94), gMotionModal.format(1), gFormat.format(42), dOutput.format(d), x, y, z, f);
                    break;
                default:
                    writeBlock(gFeedModeModal.format(94), gMotionModal.format(1), gFormat.format(40), x, y, z, f);
            }
        } else {
            writeBlock(gFeedModeModal.format(94), gMotionModal.format(1), x, y, z, f);
        }
    } else if (f) {
        if (getNextRecord().isMotion()) { // try not to output feed without motion
            feedOutput.reset(); // force feed on next line
        } else {
            writeBlock(gMotionModal.format(1), f);
        }
    }
}

function onRapid5D(_x, _y, _z, _a, _b, _c) {
    if (!currentSection.isOptimizedForMachine()) {
        error(localize("This post configuration has not been customized for 5-axis simultaneous toolpath."));
        return;
    }
    if (pendingRadiusCompensation >= 0) {
        error(localize("Radius compensation mode cannot be changed at rapid traversal."));
        return;
    }

    // get table rotations on a rotary scale
    var endABC = getABCDir(_a, _b, _c);

    var x = xOutput.format(_x);
    var y = yOutput.format(_y);
    var z = zOutput.format(_z);
    var a = aOutput.format(endABC.x);
    var b = bOutput.format(endABC.y);
    var c = cOutput.format(endABC.z);
    if (true) {
        // axes are not synchronized
        writeBlock(gMotionModal.format(1), x, y, z, a, b, c, feedOutput.format(highFeedrate));
    } else {
        writeBlock(gMotionModal.format(0), x, y, z, a, b, c);
        feedOutput.reset();
    }
    previousABC = endABC;
    feedOutput.reset();
}

function onLinear5D(_x, _y, _z, _a, _b, _c, feed) {
    if (!currentSection.isOptimizedForMachine()) {
        error(localize("This post configuration has not been customized for 5-axis simultaneous toolpath."));
        return;
    }
    if (pendingRadiusCompensation >= 0) {
        error(localize("Radius compensation cannot be activated/deactivated for 5-axis move."));
        return;
    }
    // get table rotations on a rotary scale
    var endABC = getABCDir(_a, _b, _c);

    var x = xOutput.format(_x);
    var y = yOutput.format(_y);
    var z = zOutput.format(_z);
    var a = aOutput.format(endABC.x);
    var b = bOutput.format(endABC.y);
    var c = cOutput.format(endABC.z);

    // get feed rate number
    var f = { frn: 0, fmode: 0 };
    if (a || b || c) {
        f = getMultiaxisFeed(_x, _y, _z, _a, _b, _c, feed);
        if (getProperty("useInverseTime")) {
            f.frn = inverseTimeOutput.format(f.frn);
        } else {
            f.frn = feedOutput.format(f.frn);
        }
    } else {
        f.frn = feedOutput.format(feed);
        f.fmode = 94;
    }

    if (x || y || z || a || b || c) {
        writeBlock(gFeedModeModal.format(f.fmode), gMotionModal.format(1), x, y, z, a, b, c, f.frn);
    } else if (f.frn) {
        if (getNextRecord().isMotion()) { // try not to output feed without motion
            feedOutput.reset(); // force feed on next line
        } else {
            writeBlock(gFeedModeModal.format(f.fmode), gMotionModal.format(1), f.frn);
        }
    }
    previousABC = endABC;
}

/** Calculates the rotary angles on a rotary scale */
function getABCDir(_a, _b, _c) {
    // no adjustment needed if a linear scale
    if (getProperty("rotaryScale") == "linear") {
        return new Vector(_a, _b, _c);
    }

    // calculate ABC on a rotary scale
    var endABC = new Array(_a, _b, _c);
    var startABC = new Array(Math.abs(previousABC.x), Math.abs(previousABC.y), Math.abs(previousABC.z));
    var signedABC = new Array(previousABC.x, previousABC.y, previousABC.z);

    // calculate the rotary axes directions
    for (var i = 0; i < 3; ++i) {
        // always work with angles between 0-360 degrees
        endABC[i] %= (Math.PI * 2);
        if (endABC[i] < 0) {
            endABC[i] += Math.PI * 2;
        }
        if (endABC[i] >= Math.PI * 2) {
            endABC[i] = 0;
        }

        // angles are the same
        // apply the correct sign to the new angle so it is not output
        if (!abcFormat.areDifferent(startABC[i], endABC[i])) {
            endABC[i] = signedABC[i];
        }

        // calculate the correct direction (sign) for the output angles
        // A-0 will be converted to A-360
        if (((endABC[i] - startABC[i] < 0) && (endABC[i] - startABC[i] > -Math.PI)) ||
            endABC[i] - startABC[i] > Math.PI) {
            if (endABC[i] == 0) {
                endABC[i] = -Math.PI * 2;
            } else {
                endABC[i] = -endABC[i];
            }
        }
    }
    // return the signed angles
    return new Vector(endABC[0], endABC[1], endABC[2]);
}

// Start of multi-axis feedrate logic
/***** You can add 'getProperty("useInverseTime'") if desired. *****/
/***** 'previousABC' can be added throughout to maintain previous rotary positions. Required for Mill/Turn machines. *****/
/***** 'headOffset' should be defined when a head rotary axis is defined. *****/
/***** The feedrate mode must be included in motion block output (linear, circular, etc.) for Inverse Time feedrate support. *****/
var dpmBPW = 0.1; // ratio of rotary accuracy to linear accuracy for DPM calculations
var inverseTimeUnits = 1.0; // 1.0 = minutes, 60.0 = seconds
var maxInverseTime = 9999.99; // maximum value to output for Inverse Time feeds
var maxDPM = 9999.99; // maximum value to output for DPM feeds
var useInverseTimeFeed = false; // use 1/T feeds
var inverseTimeFormat = createFormat({ decimals: 2, forceDecimal: true });
var inverseTimeOutput = createVariable({ prefix: "F", force: true }, inverseTimeFormat);
var previousDPMFeed = 0; // previously output DPM feed
var dpmFeedToler = 0.5; // tolerance to determine when the DPM feed has changed
var previousABC = new Vector(0, 0, 0); // previous ABC position if maintained in post, don't define if not used
var forceOptimized = undefined; // used to override optimized-for-angles points (XZC-mode)

/** Calculate the multi-axis feedrate number. */
function getMultiaxisFeed(_x, _y, _z, _a, _b, _c, feed) {
    var f = { frn: 0, fmode: 0 };
    if (feed <= 0) {
        error(localize("Feedrate is less than or equal to 0."));
        return f;
    }

    var length = getMoveLength(_x, _y, _z, _a, _b, _c);

    if (getProperty("useInverseTime")) { // inverse time
        f.frn = getInverseTime(length.tool, feed);
        f.fmode = 93;
        feedOutput.reset();
    } else { // degrees per minute
        f.frn = getFeedDPM(length, feed);
        f.fmode = 94;
    }
    return f;
}

/** Returns point optimization mode. */
function getOptimizedMode() {
    if (forceOptimized != undefined) {
        return forceOptimized;
    }
    // return (currentSection.getOptimizedTCPMode() != 0); // TAG:doesn't return correct value
    return true; // always return false for non-TCP based heads
}

/** Calculate the DPM feedrate number. */
function getFeedDPM(_moveLength, _feed) {
    if ((_feed == 0) || (_moveLength.tool < 0.0001) || (toDeg(_moveLength.abcLength) < 0.0005)) {
        previousDPMFeed = 0;
        return _feed;
    }
    var moveTime = _moveLength.tool / _feed;
    if (moveTime == 0) {
        previousDPMFeed = 0;
        return _feed;
    }

    var dpmFeed;
    var tcp = false; // !getOptimizedMode() && (forceOptimized == undefined);   // set to false for rotary heads
    if (tcp) { // TCP mode is supported, output feed as FPM
        dpmFeed = _feed;
    } else if (false) { // standard DPM
        dpmFeed = Math.min(toDeg(_moveLength.abcLength) / moveTime, maxDPM);
        if (Math.abs(dpmFeed - previousDPMFeed) < dpmFeedToler) {
            dpmFeed = previousDPMFeed;
        }
    } else if (false) { // combination FPM/DPM
        var length = Math.sqrt(Math.pow(_moveLength.xyzLength, 2.0) + Math.pow((toDeg(_moveLength.abcLength) * dpmBPW), 2.0));
        dpmFeed = Math.min((length / moveTime), maxDPM);
        if (Math.abs(dpmFeed - previousDPMFeed) < dpmFeedToler) {
            dpmFeed = previousDPMFeed;
        }
    } else { // machine specific calculation
        var length = Math.sqrt(Math.pow(_moveLength.tool, 2.0) + Math.pow(_moveLength.xyzLength, 2.0));
        dpmFeed = toDeg(_moveLength.abcLength) / (length / _feed);
        if (Math.abs(dpmFeed - previousDPMFeed) < dpmFeedToler) {
            dpmFeed = previousDPMFeed;
        }
    }
    previousDPMFeed = dpmFeed;
    return dpmFeed;
}

/** Calculate the Inverse time feedrate number. */
function getInverseTime(_length, _feed) {
    var inverseTime;
    if (_length < 1.e-6) { // tool doesn't move
        if (typeof maxInverseTime === "number") {
            inverseTime = maxInverseTime;
        } else {
            inverseTime = 999999;
        }
    } else {
        inverseTime = _feed / _length / inverseTimeUnits;
        if (typeof maxInverseTime === "number") {
            if (inverseTime > maxInverseTime) {
                inverseTime = maxInverseTime;
            }
        }
    }
    return inverseTime;
}

/** Calculate radius for each rotary axis. */
function getRotaryRadii(startTool, endTool, startABC, endABC) {
    var radii = new Vector(0, 0, 0);
    var startRadius;
    var endRadius;
    var axis = new Array(machineConfiguration.getAxisU(), machineConfiguration.getAxisV(), machineConfiguration.getAxisW());
    for (var i = 0; i < 3; ++i) {
        if (axis[i].isEnabled()) {
            var startRadius = getRotaryRadius(axis[i], startTool, startABC);
            var endRadius = getRotaryRadius(axis[i], endTool, endABC);
            radii.setCoordinate(axis[i].getCoordinate(), Math.max(startRadius, endRadius));
        }
    }
    return radii;
}

/** Calculate the distance of the tool position to the center of a rotary axis. */
function getRotaryRadius(axis, toolPosition, abc) {
    if (!axis.isEnabled()) {
        return 0;
    }

    var direction = axis.getEffectiveAxis();
    var normal = direction.getNormalized();
    // calculate the rotary center based on head/table
    var center;
    var radius;
    if (axis.isHead()) {
        var pivot;
        if (typeof headOffset === "number") {
            pivot = headOffset;
        } else {
            pivot = tool.getBodyLength();
        }
        if (axis.getCoordinate() == machineConfiguration.getAxisU().getCoordinate()) { // rider
            center = Vector.sum(toolPosition, Vector.product(machineConfiguration.getDirection(abc), pivot));
            center = Vector.sum(center, axis.getOffset());
            radius = Vector.diff(toolPosition, center).length;
        } else { // carrier
            var angle = abc.getCoordinate(machineConfiguration.getAxisU().getCoordinate());
            radius = Math.abs(pivot * Math.sin(angle));
            radius += axis.getOffset().length;
        }
    } else {
        center = axis.getOffset();
        var d1 = toolPosition.x - center.x;
        var d2 = toolPosition.y - center.y;
        var d3 = toolPosition.z - center.z;
        var radius = Math.sqrt(
            Math.pow((d1 * normal.y) - (d2 * normal.x), 2.0) +
            Math.pow((d2 * normal.z) - (d3 * normal.y), 2.0) +
            Math.pow((d3 * normal.x) - (d1 * normal.z), 2.0)
        );
    }
    return radius;
}

/** Calculate the linear distance based on the rotation of a rotary axis. */
function getRadialDistance(radius, startABC, endABC) {
    // calculate length of radial move
    var delta = Math.abs(endABC - startABC);
    if (delta > Math.PI) {
        delta = 2 * Math.PI - delta;
    }
    var radialLength = (2 * Math.PI * radius) * (delta / (2 * Math.PI));
    return radialLength;
}

/** Calculate tooltip, XYZ, and rotary move lengths. */
function getMoveLength(_x, _y, _z, _a, _b, _c) {
    // get starting and ending positions
    var moveLength = {};
    var startTool;
    var endTool;
    var startXYZ;
    var endXYZ;
    var startABC;
    if (typeof previousABC !== "undefined") {
        if (getProperty("rotaryScale") == "linear") {
            startABC = new Vector(previousABC.x, previousABC.y, previousABC.z);
        } else {
            startABC = new Vector(previousABC.x, previousABC.y, previousABC.z).abs;
        }
    } else {
        startABC = getCurrentDirection();
    }
    var endABC = new Vector(_a, _b, _c);

    if (!getOptimizedMode()) { // calculate XYZ from tool tip
        startTool = getCurrentPosition();
        endTool = new Vector(_x, _y, _z);
        startXYZ = startTool;
        endXYZ = endTool;

        // adjust points for tables
        if (!machineConfiguration.getTableABC(startABC).isZero() || !machineConfiguration.getTableABC(endABC).isZero()) {
            startXYZ = machineConfiguration.getOrientation(machineConfiguration.getTableABC(startABC)).getTransposed().multiply(startXYZ);
            endXYZ = machineConfiguration.getOrientation(machineConfiguration.getTableABC(endABC)).getTransposed().multiply(endXYZ);
        }

        // adjust points for heads
        if (machineConfiguration.getAxisU().isEnabled() && machineConfiguration.getAxisU().isHead()) {
            if (typeof getOptimizedHeads === "function") { // use post processor function to adjust heads
                startXYZ = getOptimizedHeads(startXYZ.x, startXYZ.y, startXYZ.z, startABC.x, startABC.y, startABC.z);
                endXYZ = getOptimizedHeads(endXYZ.x, endXYZ.y, endXYZ.z, endABC.x, endABC.y, endABC.z);
            } else { // guess at head adjustments
                var startDisplacement = machineConfiguration.getDirection(startABC);
                startDisplacement.multiply(headOffset);
                var endDisplacement = machineConfiguration.getDirection(endABC);
                endDisplacement.multiply(headOffset);
                startXYZ = Vector.sum(startTool, startDisplacement);
                endXYZ = Vector.sum(endTool, endDisplacement);
            }
        }
    } else { // calculate tool tip from XYZ, heads are always programmed in TCP mode, so not handled here
        startXYZ = getCurrentPosition();
        endXYZ = new Vector(_x, _y, _z);
        startTool = machineConfiguration.getOrientation(machineConfiguration.getTableABC(startABC)).multiply(startXYZ);
        endTool = machineConfiguration.getOrientation(machineConfiguration.getTableABC(endABC)).multiply(endXYZ);
    }

    // calculate axes movements
    moveLength.xyz = Vector.diff(endXYZ, startXYZ).abs;
    moveLength.xyzLength = moveLength.xyz.length;
    moveLength.abc = Vector.diff(endABC, startABC).abs;
    for (var i = 0; i < 3; ++i) {
        if (moveLength.abc.getCoordinate(i) > Math.PI) {
            moveLength.abc.setCoordinate(i, 2 * Math.PI - moveLength.abc.getCoordinate(i));
        }
    }
    moveLength.abcLength = moveLength.abc.length;

    // calculate radii
    moveLength.radius = getRotaryRadii(startTool, endTool, startABC, endABC);

    // calculate the radial portion of the tool tip movement
    var radialLength = Math.sqrt(
        Math.pow(getRadialDistance(moveLength.radius.x, startABC.x, endABC.x), 2.0) +
        Math.pow(getRadialDistance(moveLength.radius.y, startABC.y, endABC.y), 2.0) +
        Math.pow(getRadialDistance(moveLength.radius.z, startABC.z, endABC.z), 2.0)
    );

    // calculate the tool tip move length
    // tool tip distance is the move distance based on a combination of linear and rotary axes movement
    moveLength.tool = moveLength.xyzLength + radialLength;

    // debug
    if (false) {
        writeComment("DEBUG - tool   = " + moveLength.tool);
        writeComment("DEBUG - xyz    = " + moveLength.xyz);
        var temp = Vector.product(moveLength.abc, 180 / Math.PI);
        writeComment("DEBUG - abc    = " + temp);
        writeComment("DEBUG - radius = " + moveLength.radius);
    }
    return moveLength;
}
// End of multi-axis feedrate logic

// stub function required for tables without limits
function onRewindMachine() {
}

function onCircular(clockwise, cx, cy, cz, x, y, z, feed) {
    if (pendingRadiusCompensation >= 0) {
        if (getCircularPlane() != PLANE_XY) {
            error(localize("Radius compensation cannot be activated/deactivated for circular move in other plane than the XY-plane."));
            return;
        }
    }

    var crc = [];
    if (pendingRadiusCompensation >= 0) {
        validate(getCircularPlane() == PLANE_XY, "Circular moves must be in the XY plane when using radius compensation.");

        // ensure that we end at desired position when compensation is turned off
        xOutput.reset();
        yOutput.reset();

        pendingRadiusCompensation = -1;
        var d = tool.diameterOffset;
        if (d > 200) {
            warning(localize("The diameter offset exceeds the maximum value."));
        }

        switch (radiusCompensation) {
            case RADIUS_COMPENSATION_LEFT:
                dOutput.reset();
                crc = [gFormat.format(41), dOutput.format(d)];
                break;
            case RADIUS_COMPENSATION_RIGHT:
                dOutput.reset();
                crc = [gFormat.format(42), dOutput.format(d)];
                break;
            default:
                crc = [gFormat.format(40)];
        }
    }

    var start = getCurrentPosition();

    if (isFullCircle()) {
        if (isHelical()) {
            linearize(tolerance);
            return;
        }
        switch (getCircularPlane()) {
            case PLANE_XY:
                writeBlock(gPlaneModal.format(17), gFeedModeModal.format(94), gMotionModal.format(clockwise ? 2 : 3), crc, iOutput.format(cx - start.x, 0), jOutput.format(cy - start.y, 0), feedOutput.format(feed));
                break;
            case PLANE_ZX:
                writeBlock(gPlaneModal.format(18), gFeedModeModal.format(94), gMotionModal.format(clockwise ? 2 : 3), iOutput.format(cx - start.x, 0), kOutput.format(cz - start.z, 0), feedOutput.format(feed));
                break;
            case PLANE_YZ:
                writeBlock(gPlaneModal.format(19), gFeedModeModal.format(94), gMotionModal.format(clockwise ? 2 : 3), jOutput.format(cy - start.y, 0), kOutput.format(cz - start.z, 0), feedOutput.format(feed));
                break;
            default:
                linearize(tolerance);
        }
    } else {
        switch (getCircularPlane()) {
            case PLANE_XY:
                writeBlock(gPlaneModal.format(17), gFeedModeModal.format(94), gMotionModal.format(clockwise ? 2 : 3), crc, xOutput.format(x), yOutput.format(y), zOutput.format(z), iOutput.format(cx - start.x, 0), jOutput.format(cy - start.y, 0), feedOutput.format(feed));
                break;
            case PLANE_ZX:
                writeBlock(gPlaneModal.format(18), gFeedModeModal.format(94), gMotionModal.format(clockwise ? 2 : 3), xOutput.format(x), yOutput.format(y), zOutput.format(z), iOutput.format(cx - start.x, 0), kOutput.format(cz - start.z, 0), feedOutput.format(feed));
                break;
            case PLANE_YZ:
                writeBlock(gPlaneModal.format(19), gFeedModeModal.format(94), gMotionModal.format(clockwise ? 2 : 3), xOutput.format(x), yOutput.format(y), zOutput.format(z), jOutput.format(cy - start.y, 0), kOutput.format(cz - start.z, 0), feedOutput.format(feed));
                break;
            default:
                linearize(tolerance);
        }
    }
}

var currentCoolantMode = COOLANT_OFF;
var coolantOff = undefined;

function setCoolant(coolant) {
    var coolantCodes = getCoolantCodes(coolant);
    if (Array.isArray(coolantCodes)) {
        if (singleLineCoolant) {
            writeBlock(coolantCodes.join(getWordSeparator()));
        } else {
            for (var c in coolantCodes) {
                writeBlock(coolantCodes[c]);
            }
        }
        return undefined;
    }
    return coolantCodes;
}

function getCoolantCodes(coolant) {
    var multipleCoolantBlocks = new Array(); // create a formatted array to be passed into the outputted line
    if (!coolants) {
        error(localize("Coolants have not been defined."));
    }
    if (isProbeOperation()) { // avoid coolant output for probing
        coolant = COOLANT_OFF;
    }
    if (coolant == currentCoolantMode) {
        return undefined; // coolant is already active
    }
    if ((coolant != COOLANT_OFF) && (currentCoolantMode != COOLANT_OFF) && (coolantOff != undefined)) {
        if (Array.isArray(coolantOff)) {
            for (var i in coolantOff) {
                multipleCoolantBlocks.push(mFormat.format(coolantOff[i]));
            }
        } else {
            multipleCoolantBlocks.push(mFormat.format(coolantOff));
        }
    }

    var m;
    var coolantCodes = {};
    for (var c in coolants) { // find required coolant codes into the coolants array
        if (coolants[c].id == coolant) {
            coolantCodes.on = coolants[c].on;
            if (coolants[c].off != undefined) {
                coolantCodes.off = coolants[c].off;
                break;
            } else {
                for (var i in coolants) {
                    if (coolants[i].id == COOLANT_OFF) {
                        coolantCodes.off = coolants[i].off;
                        break;
                    }
                }
            }
        }
    }
    if (coolant == COOLANT_OFF) {
        m = !coolantOff ? coolantCodes.off : coolantOff; // use the default coolant off command when an 'off' value is not specified
    } else {
        coolantOff = coolantCodes.off;
        m = coolantCodes.on;
    }

    if (!m) {
        onUnsupportedCoolant(coolant);
        m = 9;
    } else {
        if (Array.isArray(m)) {
            for (var i in m) {
                multipleCoolantBlocks.push(mFormat.format(m[i]));
            }
        } else {
            multipleCoolantBlocks.push(mFormat.format(m));
        }
        currentCoolantMode = coolant;
        return multipleCoolantBlocks; // return the single formatted coolant value
    }
    return undefined;
}

var mapCommand = {
    COMMAND_STOP: 0,
    COMMAND_OPTIONAL_STOP: 1,
    COMMAND_END: 2,
    COMMAND_SPINDLE_CLOCKWISE: 3,
    COMMAND_SPINDLE_COUNTERCLOCKWISE: 4,
    COMMAND_STOP_SPINDLE: 5,
    COMMAND_ORIENTATE_SPINDLE: 19,
    COMMAND_LOAD_TOOL: 6
};

function onCommand(command) {
    switch (command) {
        case COMMAND_START_SPINDLE:
            onCommand(tool.clockwise ? COMMAND_SPINDLE_CLOCKWISE : COMMAND_SPINDLE_COUNTERCLOCKWISE);
            return;
        case COMMAND_LOCK_MULTI_AXIS:
            return;
        case COMMAND_UNLOCK_MULTI_AXIS:
            return;
        case COMMAND_BREAK_CONTROL:
            checkToolBreakage(tool);
            return;
        case COMMAND_TOOL_MEASURE:
            measureTool(tool);
            return;
    }

    var stringId = getCommandStringId(command);
    var mcode = mapCommand[stringId];
    if (mcode != undefined) {
        writeBlock(mFormat.format(mcode));
    } else {
        onUnsupportedCommand(command);
    }
}

function prepareForToolCheck(t) {
    onCommand(COMMAND_STOP_SPINDLE);
    setCoolant(COOLANT_OFF);

    if ((currentSection.isMultiAxis() && getCurrentDirection().length != 0) ||
        (currentMachineABC != undefined && currentMachineABC.length != 0)) {
        setWorkPlane(new Vector(0, 0, 0));
        forceWorkPlane();
    }
    writeRetract(Z);
}

function checkToolBreakage(t) {
    prepareForToolCheck(t);
    writeComment("Checking Tool " + toolFormat.format(t.number) + " for breakage")

    // Move to the tool setter wcs but shifted on Y to account for tool and probe diameter
    writeBlock(
        gFormat.format(0),
        eFormat.format(getProperty("toolSetterOffset")),
        xOutput.format(0),
        yOutput.format(-1 * (t.diameter / 2 + .5))
    );

    // Move down to just below the tool probe top surface
    writeBlock(
        hFormat.format(t.lengthOffset),
        zOutput.format(0 - getProperty("toolBreakageTolerance")),
        mFormat.format(65)
    );
    // Feed in to Y 0 to detect a touch
    writeBlock(
        gFormat.format(31),
        yOutput.format(0),
        feedFormat.format(25),
        "P1"
    );

    // Launch the tool breakage probe macro
    writeBlock("L9101 R1+6.");

    writeRetract(Z);
}

function measureTool(t) {

}

// Get the measuring type from the tool type
function getToolType(toolType) {
    switch (toolType) {
        case TOOL_DRILL:
        case TOOL_REAMER:
            return 1; // drill
        case TOOL_TAP_RIGHT_HAND:
        case TOOL_TAP_LEFT_HAND:
            return 2; // tap
        case TOOL_MILLING_FACE:
        case TOOL_MILLING_SLOT:
        case TOOL_BORING_BAR:
            return 3; // shell mill
        case TOOL_MILLING_END_FLAT:
        case TOOL_MILLING_END_BULLNOSE:
        case TOOL_MILLING_TAPERED:
        case TOOL_MILLING_DOVETAIL:
            return 4; // end mill
        case TOOL_DRILL_SPOT:
        case TOOL_MILLING_CHAMFER:
        case TOOL_DRILL_CENTER:
        case TOOL_COUNTER_SINK:
        case TOOL_COUNTER_BORE:
        case TOOL_MILLING_THREAD:
        case TOOL_MILLING_FORM:
            return 5; // center drill
        case TOOL_MILLING_END_BALL:
        case TOOL_MILLING_LOLLIPOP:
            return 6; // ball nose
        case TOOL_PROBE:
            return 7; // probe
        default:
            error(localize("Invalid tool type."));
            return -1;
    }
}

function writeToolMeasureBlock(tool, preMeasure) {
    var comment = measureTool ? writeComment("MEASURE TOOL") : "";
    if (!preMeasure) {
        prepareForToolCheck();

        writeBlock("T" + toolFormat.format(tool.number), mFormat.format(6)); // get tool
        writeBlock(
            gFormat.format(65),
            "P9995",
            "A0.",
            "B" + getHaasToolType(tool.type) + ".",
            "C" + getHaasProbingType(tool.type, false) + ".",
            "T" + toolFormat.format(tool.number),
            "E" + xyzFormat.format(getBodyLength(tool)),
            "D" + xyzFormat.format(tool.diameter),
            "K" + xyzFormat.format(0.1),
            "I0.",
            comment
        ); // probe tool
    }
    measureTool = false;
}

function measureToolDiameter(tool) {
    prepareForToolCheck(t);
    writeComment("Checking Tool " + toolFormat.format(t.number) + " for breakage")

    // Move to the tool setter wcs but shifted on Y to account for tool and probe diameter
    writeBlock(
        gFormat.format(0),
        eFormat.format(getProperty("toolSetterOffset")),
        xOutput.format(0),
        yOutput.format(-1 * (t.diameter / 2 + .5))
    );

    // Move down to just below the tool probe top surface
    writeBlock(
        hFormat.format(t.lengthOffset),
        zOutput.format(0 - getProperty("toolBreakageTolerance")),
        mFormat.format(65)
    );
    // Feed in to Y 0 to detect a touch
    writeBlock(
        gFormat.format(31),
        yOutput.format(0),
        feedFormat.format(25),
        "P1"
    );

    // Launch the tool breakage probe macro
    writeBlock("L9101 R1+6.");

    writeRetract(Z);
    // N1 G0 G90 S500 M4 E24 X0 Y-.5 (.200+.25+.05
    //   N2 H1 Z-.1 M65
    //   N3 G1 G31 Y0 F5. P1
    //   N4 G0 Z.1
    //   N5 Y.5
    //   N6 Z-.1
    //   N7 G1 G31 Y0 P2
    //   N8 L9101 R1+8. R2+.4 D1
    //   N1: The E24 shifts the XY zero to the center and the Z zero to the top of the
    //   stylus. The X0 moves to the center of the stylus. The Y-.5 moves to a clearance
    //   position, calculated as follows:
    //   1/2 the width of the stylus: .200
    //   1/2 the approximate tool diameter: .250
    //   Clearance: .050
    //   N2: moves the tip of the tool .100" below the top of the stylus while spinning
    //   the tool backwards at 500 RPM.
    //   N3: moves to touch point 1.
    //   N4: moves Z .100 above the stylus.
    //   N5: moves to a clearance position in preparation for the next touch.
    //   N6: moves Z below the top of the stylus.
    //   N7: moves to touch point 2.
    //   N8: performs the diameter calculation.

    //   The stylus width is specified by R2. The D word specifies the diameter is to be stored as offset 1 in the tool table.

}

function onSectionEnd() {
    writeBlock(gPlaneModal.format(17));
    if (!isLastSection() && (getNextSection().getTool().coolant != tool.coolant)) {
        setCoolant(COOLANT_OFF);
    }
    forceAny();

    if (currentSection.isMultiAxis()) {
        writeBlock(gFeedModeModal.format(94)); // inverse time feed off
    }
    if (tapping && (getProperty("format") == 1)) {
        writeBlock(gAccDecModal.format(9));
    }
}

/** Output block to do safe retract and/or move to home position. */
function writeRetract() {
    var words = []; // store all retracted axes in an array
    var retractAxes = new Array(false, false, false);
    var method = getProperty("safePositionMethod");
    if (method == "clearanceHeight") {
        if (!is3D()) {
            error(localize("Retract option 'Clearance Height' is not supported for multi-axis machining."));
        } else {
            return;
        }
    }
    validate(arguments.length != 0, "No axis specified for writeRetract().");

    for (i in arguments) {
        retractAxes[arguments[i]] = true;
    }
    if ((retractAxes[0] || retractAxes[1]) && !retracted) { // retract Z first before moving to X/Y home
        error(localize("Retracting in X/Y is not possible without being retracted in Z."));
        return;
    }

    // define home positions
    var _xHome;
    var _yHome;
    var _zHome;
    _xHome = machineConfiguration.hasHomePositionX() ? machineConfiguration.getHomePositionX() : toPreciseUnit(0, MM);
    _yHome = machineConfiguration.hasHomePositionY() ? machineConfiguration.getHomePositionY() : toPreciseUnit(0, MM);
    if (getProperty("longToolClearance")) {
        _zHome = toPreciseUnit(4, IN);
    }
    else {
        _zHome = toPreciseUnit(0, IN);
    }
    for (var i = 0; i < arguments.length; ++i) {
        switch (arguments[i]) {
            case X:
                words.push("X" + xyzFormat.format(_xHome));
                xOutput.reset();
                break;
            case Y:
                words.push("Y" + xyzFormat.format(_yHome));
                yOutput.reset();
                break;
            case Z:
                words.push("Z" + xyzFormat.format(_zHome));
                zOutput.reset();
                retracted = true;
                break;
            default:
                error(localize("Unsupported axis specified for writeRetract()."));
                return;
        }
    }
    if (words.length > 0) {
        switch (method) {
            case "machineHome":
                // 90/91 mode is don't care
                if (getProperty("format") == 1) {
                    if (retractAxes[2]) { // Z axis retract
                        writeBlock(gAbsIncModal.format(90), gMotionModal.format(0), hFormat.format(0), words);
                    } else {
                        writeBlock(gAbsIncModal.format(90), eFormat.format(0), gMotionModal.format(0), words);
                    }
                } else {
                    if (retractAxes[2]) { // Z axis retract
                        writeBlock(gFormat.format(28), gAbsIncModal.format(91), words);
                        writeBlock(gAbsIncModal.format(90));
                    } else {
                        writeBlock(gAbsIncModal.format(90), gMotionModal.format(0));
                        writeBlock(gFormat.format(53), words);
                    }
                }
                break;
            default:
                error(localize("Unsupported safe position method."));
                return;
        }
    }
}

function onClose() {
    writeln("");

    optionalSection = false;

    setCoolant(COOLANT_OFF);
    writeRetract(Z);

    setWorkPlane(new Vector(0, 0, 0)); // reset working plane

    writeRetract(X, Y);

    onImpliedCommand(COMMAND_END);
    onImpliedCommand(COMMAND_STOP_SPINDLE);
    writeBlock(mFormat.format(30)); // stop program, spindle stop, coolant off
    writeln("%");
}

function setProperty(property, value) {
    properties[property].current = value;
}
