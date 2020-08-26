@def title = "Side Quests"

## Miscellaneous PR's
Apart from the two main PR's mentioned in the ~~~<a href="/blog_pages/workflow">Workflow blog</a>~~~, I was able to contribute to

-----------
## GeometryBasics.jl
* Tests for GeometryBasics : ~~~<a href="https://github.com/JuliaGeometry/GeometryBasics.jl/pull/42">#42</a>~~~ & ~~~<a href="https://github.com/JuliaGeometry/GeometryBasics.jl/pull/44">#44</a>~~~ 
* Added `MultiLineStringMeta` ~~~<a href="https://github.com/JuliaGeometry/GeometryBasics.jl/pull/53">#53</a>~~~, `PolygonMeta` and `LineStringMeta`~~~<a href="https://github.com/JuliaGeometry/GeometryBasics.jl/pull/65"> #65</a>~~~ meta-geometry methods based on the `@meta_type` macro. 
* A `MetaT` method to support the case of heterogeneous geometries or metadata like we discussed in the previous blog : ~~~<a href="https://github.com/JuliaGeometry/GeometryBasics.jl/pull/74"> #74</a>~~~ and docs for metadata ~~~<a href="https://github.com/JuliaGeometry/GeometryBasics.jl/pull/79"> #79</a>~~~
-----------
## ArchGDAL.jl
* [WIP] ~~~<a href="https://github.com/JuliaData/Tables.jl/">Tables.jl</a>~~~ Interface for `ArchGDAL` feature layers ~~~<a href="https://github.com/yeesian/ArchGDAL.jl/pull/118">#118</a>~~~ (minor ~~~<a href="https://github.com/yeesian/ArchGDALDatasets/pull/1">#1</a>~~~)
-----------
## AbstractPlotting.jl(Makie ecosystem)
* Add overloads for `convert_arguments` method to support plotting of GeometryBasics ~~~<a href="https://github.com/JuliaPlots/AbstractPlotting.jl/pull/479">LineString / Array{LineString}/ MultiLineString</a>~~~ and ~~~<a href="https://github.com/JuliaPlots/AbstractPlotting.jl/pull/486">Polygon / Array{Polygon}</a>~~~.
* I was hacking around my old ~~~<a href="https://www.amd.com/en/products/graphics/radeon-530">AMD GPU</a>~~~ in linux and acutally found way to invoke GPU's with "not so good" linux drivers to render `Makie` plots, right from bash terminal which made it's way into the Makie docs ~~~<a href="https://github.com/JuliaPlots/MakieGallery.jl/pull/295">#295</a>~~~
-----------
## DataFrames.jl
* Added an overload for `Base.isapprox()` method to allow for testing approximate equality between two DataFrames ~~~<a href="https://github.com/JuliaData/DataFrames.jl/pull/2373">#2373</a>~~~
-----------
## StructArrays.jl
* In the previous blog I talked about working around the `StructArrays` API methods to allow for heterogeneous features in `GeoJSONTables`. Thanks to ~~~<a href="https://github.com/piever/">Pietro Vertechi</a>~~~ for helping us out. The method also made it's way to the StructArrays readme ~~~<a href="https://github.com/JuliaArrays/StructArrays.jl/pull/149">#149</a>~~~