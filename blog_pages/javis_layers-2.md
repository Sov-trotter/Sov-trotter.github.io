@def title = "Layers-v2"
@def date = Date(2021, 07, 04)

### शाश्वतं जीवनम् , अमरं प्रेम । 
######  _Eternal Life, Undying Passion._
---
Continuing from the previous blog, where my mentor suggested an altogether new approach which involved looking at each layer, not as an `Object` but as a `Drawing`.
~~~<img src="/assets/layers_idea.png">~~~
_~~~<pre>Credits: <a href="https://github.com/TheCedarPrince">Jacob Zelko</a></pre>~~~_

##### What if we treated the layer as it's own rendering process?
~~~<a href="https://github.com/Wikunia/Javis.jl/pull/343">#343</a>~~~ encapsulates the above idea!

Here's how this approach works:
* Layers are pushed to `video.layers` while independent objects(objects which don't belong to any layer) remain in `video.objects`.
* Rendering is now a three step process:

```julia
for each frame in the video
    if layers exist

    1)  render(the layers as drawings, compute their actions and save their image matrices and settings based 
         on the computed actions)
    
    2)  create(an empty drawing(same size as the main video) and apply the actions on each layer) 
         place(the respective layer's image matrices on the empty drawing)
     end


    3) # finally 
    render(all the independent objects on the main drawing)
    place(the drawing containing all the layers from step two on the main drawing)
end
```

* The layer declaration is a specialized macro viz. `@JLayer` that handles all the object/action declarations. 

```julia
l1 = @JLayer 10:70 100 100 Point(150, 150) begin
    red_ball = Object(20:60, (args...)->object(O, "red"), Point(50,0))
    act!(red_ball, Action(anim_rotate_around(2π, O)))
end

l2 = @JLayer 71:100 begin
    p = [Point(-1.0, 0.0), Point(1.0, 0.0), Point(0.0, 1.0)]
    Object(40:100, (args...) -> poly(p, :stroke))
end

act!(l1, appear(:fade))
act!(l2, anim_translate(Point(100, 100)))
```

* One can also loop specific frame(s) of a layer after they have been rendered at any point in the video using the `show_layer_frames()` method.
* Actions on a layer are applied in a different fashion as compared to objects. Now the layer actions are applied to their respective image matrices rather than their constituent objects, just like we wanted. This also resulted in a ~~~<a href="https://github.com/JuliaGraphics/Luxor.jl/pull/156">mini side-quest</a>~~~.
* Objects can be pushed to a layer outside the `@JLayer` macro using `to_layer` method.

# Layers Gallery 

Coming Soon!