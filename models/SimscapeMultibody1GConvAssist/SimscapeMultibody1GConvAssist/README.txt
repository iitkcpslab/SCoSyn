Simscape Multibody 1G Conversion Assistant
Copyright 2014-2017 The MathWorks, Inc.

This set of files provides assistance when you convert a model built using
Simscape Multibody First Generation Technology (1G) to Second Generation (2G).
Note that if you import your model using Simscape Multibody Link, you can
more easily convert to Second Generation Technology simply by exporting to
Second Generation.

The assistant indicates which constructs in your 1G model are not permitted in
2G technology, and indicate how you can adjust your model to be compatible
with the modeling conventions in 2G.  It assistant will also convert individual
blocks (bodies, joints), maintaining parameterization when possible.  You will
then need to assemble the converted blocks into a complete model.

The PDF file included in this submission contains more details and a brief
tutorial that explains how to test the conversion assistant on an example.

This code has been tested on releases R2013a and later.  It uses MATLAB command
strsplit() which was introduced in R2013a.

#########  Release History  #########  
v 1.0 		April  2017	Initial release

		Initial release with a few examples and documentation.
