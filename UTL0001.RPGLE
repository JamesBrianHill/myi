**FREE
//--------------------------------------------------------------------------------------------------
//   This source member shows how to generate a Universally Unique Identifier or UUID. This is also
// sometimes called a GUID (Globally Unique Identifier).
//
// Lines of code:        29 (17.4%)
// Lines of comments:   125 (74.8%)
// Lines of whitespace:  13 ( 7.8%)
// Total lines:         167
//
// @author James Brian Hill
// @copyright James Brian Hill
// @license GNU General Public License version 3
//
// Using **FREE to enable completely free-format source members:
// https://www.ibm.com/support/knowledgecenter/en/ssw_ibm_i_74/rzasd/ssfree.htm
//--------------------------------------------------------------------------------------------------

//--------------------------------------------------------------------------------------------------
//   This program is free software: you can redistribute it and/or modify it under the terms of the
// GNU General Public License as published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
//   This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
// without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
//   You should have received a copy of the GNU General Public License along with this program. If
// not, see <https://www.gnu.org/licenses/>.
//--------------------------------------------------------------------------------------------------
//   This source code was developed at www.pub400.com, a service provided by RZKH GmbH. Thank you!
//--------------------------------------------------------------------------------------------------

//--------------------------------------------------------------------------------------------------
// Control options.
//
// Free-Form Control Statement information:
// https://www.ibm.com/support/knowledgecenter/en/ssw_ibm_i_74/rzasd/freectlopt.htm
//
// ACTGRP keyword:
// https://www.ibm.com/docs/en/i/7.4?topic=keywords-actgrpstgmdl-new-caller-activation-group-name
//
//--------------------------------------------------------------------------------------------------
CTL-OPT ACTGRP(*CALLER);

//--------------------------------------------------------------------------------------------------
// Define the call to IBM's procedure for creating a UUID.
//
// Machine Interface Instruction GENUUID:
// https://www.ibm.com/docs/en/i/7.4?topic=instructions-generate-universal-unique-identifier-genuuid
//
// Defining a prototype:
// https://www.ibm.com/docs/en/i/7.4?topic=parameters-prototypes#ptyp
//
// Defining prototype parameters:
// https://www.ibm.com/docs/en/i/7.4?topic=statement-free-form-parameter-definition
// https://www.ibm.com/docs/en/i/7.4?topic=parameters-prototyped
//
// POINTER data type:
// https://www.ibm.com/docs/en/i/7.4?topic=formats-basing-pointer-data-type
//
// @parm 1 REQUIRED: the address of the uuid_ds data structure.
//--------------------------------------------------------------------------------------------------
DCL-PR GenerateUUID EXTPROC('_GENUUID');
  *N POINTER VALUE; // Address of uuid_ds
END-PR GenerateUUID;

//--------------------------------------------------------------------------------------------------
// Define the call to IBM's procedure for converting a character string to a hexadecimal string.
//
// Machine Interface Instruction CVTHC:
// https://www.ibm.com/docs/en/i/7.4?topic=instructions-convert-hex-character-cvthc
//
// The C prototype we are calling can be found in QSYSINC/MIH/cvthc.c
//
// @parm 1 REQUIRED: address of hexadecimal string.
// @parm 2 REQUIRED: address of binary character string.
// @parm 3 REQUIRED: length of binary character string.
//--------------------------------------------------------------------------------------------------
DCL-PR CharToHex EXTPROC('cvthc');
  *N POINTER VALUE; // Address of hex string.
  *N POINTER VALUE; // Address of character string.
  *N INT(10) VALUE; // Length of the character string.
END-PR CharToHex;

//--------------------------------------------------------------------------------------------------
// Define a data structure containing the information needed by _GENUUID.
//
// bytes_provided is provided as input and is the size of this data structure.
// bytes_available is output by _GENUUID.
// version is the version of UUID to be generated. We want version 4 (RFC 4122 UUID).
// reserved MUST be set to hexadecimal zeros (NULLs) or you will receive an error.
// uuid will contain the generated UUID.
//
// More about UUID versions. Note that _GENUUID supports a version = 0 or 1 (which returns a version
// 1 DCE). Version = 4 generates an RFC 4122 UUID.
// https://en.wikipedia.org/wiki/Universally_unique_identifier#Versions
//
// Free form Data Structure definition (DCL-DS):
// https://www.ibm.com/docs/en/i/7.4?topic=statement-free-form-data-structure-definition
//
// QUALIFIED keyword:
// https://www.ibm.com/docs/en/i/7.4?topic=dsk-qualified#dqualif
//
// CHAR keyword (character data type):
// https://www.ibm.com/docs/en/i/7.4?topic=keywords-charlength#dkwchar
//
// UNS keyword (unsigned data type):
// https://www.ibm.com/docs/en/i/7.4?topic=keywords-unsdigits#dkwuns
//
// INZ keyword:
// https://www.ibm.com/docs/en/i/7.4?topic=keywords-inzinitial-value
//
// %SIZE built in function:
// https://www.ibm.com/docs/en/i/7.4?topic=functions-size-get-size-in-bytes
//--------------------------------------------------------------------------------------------------
DCL-DS uuid_ds QUALIFIED;
  bytes_provided UNS(10) INZ(%SIZE(uuid_ds));
  bytes_available UNS(10) INZ(0);
  version UNS(3) INZ(4);
  reserved CHAR(7) INZ(*ALLx'00');
  uuid CHAR(16) INZ(*BLANKS);
END-DS uuid_ds;

//--------------------------------------------------------------------------------------------------
// Define variables we will use in this program.
// display_string will be used with the DSPLY opcode.
// uuid_hex_string will hold the hexadecimal representation of the generated UUID. Note that it is
//   exactly twice as large as the 16-character uuid field in the uuid_ds data structure.
//--------------------------------------------------------------------------------------------------
DCL-S display_string CHAR(52);
DCL-S uuid_hex_string CHAR(32);

//--------------------------------------------------------------------------------------------------
// Main program logic.
//
// Information about indicator LR:
// https://www.ibm.com/docs/en/i/7.4?topic=indicators-last-record-indicator-lr
//--------------------------------------------------------------------------------------------------
*INLR = *ON;

// Call the _GENUUID API and pass the address of our uuid_ds data structure.
// %ADDR built in function:
// https://www.ibm.com/docs/en/i/7.4?topic=functions-addr-get-address-variable
GenerateUUID(%ADDR(uuid_ds));

// Convert the binary character string to hexadecimal so we can display it.
// %LEN built in function:
// https://www.ibm.com/docs/en/i/7.4?topic=functions-len-get-set-length
CharToHex(%ADDR(uuid_hex_string) : %ADDR(uuid_ds.uuid) : %LEN(uuid_hex_string));

// Now format our hexadecimal UUID for display.
// %SUBST built in function:
// https://www.ibm.com/docs/en/i/7.4?topic=functions-subst-get-substring
display_string = %SUBST(uuid_hex_string: 1: 8) + '-' +
                 %SUBST(uuid_hex_string: 9: 4) + '-' +
                 %SUBST(uuid_hex_string: 13: 4) + '-' +
                 %SUBST(uuid_hex_string: 17: 4) + '-' +
                 %SUBST(uuid_hex_string: 21);

// Display our formatted UUID.
// DSPLY opcode:
// https://www.ibm.com/docs/en/i/7.4?topic=codes-dsply-display-message#zzdsply
DSPLY display_string;

RETURN;
