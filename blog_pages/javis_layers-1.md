@def title = "Layers in Javis"
@def date = Date(2021, 07, 04)


### सदैव देवत्वं दर्शयामि । 
######  _I always manifest divinity._
---
Most standard tools for vector graphics/animations(eg: ~~~<a href="https://inkscape.org/">Inkscape</a>~~~, ~~~<a href="https://www.gimp.org/GIMP">GIMP</a>~~~ etc.) follow a layer based approach towards the entire canvas, where different layers are stacked on top of each other(or together in a list). 

~~~<img src="https://sozi.baierouge.fr/images/tutorial-layers/sozi-layers-tutorial-screenshot-02.png">~~~

_~~~<pre><a href="https://sozi.baierouge.fr/pages/tutorial-layers.html">Layers in Inkscape</a></pre>~~~_

A similar feature in Javis could add new capablities to animation with Javis. 

But let's pause and ponder over what features we wish, a Javis Layer must have.
* Layers can define their own  properties such as color, size, frame range etc
* Properties will be local for a layer and apply to all the objects in that layer.
* Actions defined over a particular object automatically become a part of the layer based on the frame range.
* A layer can constitute multiple objects and sub-layers (as children) which inherit the  properties of the parent layer. Hence the canvas tends to have a “tree-like” structure. 
~~~<img src="https://user-images.githubusercontent.com/43717431/120858679-c1b16600-c5a0-11eb-8198-3e9575c65503.png">~~~


There are two main challenges to be tackled before layers in Javis becomes a reality:
* Every layer should be independent of other layer in the canvas.
~~~<img src="https://wikunia.github.io/Javis.jl/dev/assets/showcase.gif">~~~
This would require every layer to have a separate context(position, size, settings etc.)

* One ahould be able to apply actions to each layer. 
A simple example is if I want to show the animation of a planet and then move it to some place like the bottom of the canvas.
~~~<img src="https://github.com/Sov-trotter/Javis-viz/blob/main/doc-files/layer_intial.gif?raw=true">~~~

This needs some out-of-the-box thinking since actions on a layer should be applied to the layer as a whole and not it's constituent objects.

The above challenges become more interesting due to the fact that Javis is based on ~~~<a href="https://github.com/JuliaGraphics/Luxor.jl">Luxor</a>~~~ which is itself based on ~~~<a href="https://www.cairographics.org/">Cairo</a>~~~ which don't have such context in-built.

Luxor does have some comparable contexts eg: A `Drawing` and a `@layer`.
While a `Drawing` is a complete canvas, `@layer` seems like the obvious way to go and this holds well al long as each layer is a `AbstractObject`.
~~~<a href="https://github.com/Wikunia/Javis.jl/pull/341">#341</a>~~~ explores this idea.
.

.

.

.

.

After a few trials we ran into a problem with this direct implemenation:
While we did have a tree-like structure, we realized that it was applying layer's actions on individual objects rather than the entire layer. 

And the output came out someting like:

~~~<img src="https://github.com/Sov-trotter/Javis-viz/blob/main/doc-files/layer_test.gif?raw=true">~~~

.
 
.

:(

.


I was almost about to give up when one of my amazing mentors ~~~<a href="https://github.com/TheCedarPrince">Jacob Zelko</a>~~~ stepped in with his genius and suggested an altogether new approach!

~~~<img src=https://media1.tenor.com/images/57952baad34378449b065261352889e3/tenor.gif?itemid=20676729>~~~

Cont....