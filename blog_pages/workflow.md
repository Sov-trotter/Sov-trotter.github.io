@def title = "Workflow"

# GeometryBasics support
## ~~~<a href="https://github.com/JuliaGeo/Shapefile.jl/pull/39">Shapefile.jl</a>~~~:
* `GeoInterface` geometry types are replaced by the meta-geometry types from `GeometryBasics`
```julia
const Point = Point{2, Float64}

const MultiPoint = typeof(MultiPointMeta(y::Float64[Point(0)], m::Float64, 
                                         boundingbox=Rect(0.0, 0.0, 2.0, 2.0))) 

# and so on for other shapefile geometries
```

* Geometry contructors:
The construction of geometries is pretty simple as such and is handled well by `GeometryBasics` meta-geometry constructors, except for `Polygon` where we had to take an extra dependency to capture the case where it might have ~~~<a href="https://gist.github.com/jkrumbiegel/b82def0a3fb0a822963ec7f97278190c">multiple exterior rings</a>~~~. ~~~<br>~~~Thanks to ~~~<a href="https://github.com/greimel">Fabian Greimel</a>~~~, who ~~~<a href="https://github.com/JuliaGeo/Shapefile.jl/pull/39#issuecomment-671595669">solved</a>~~~ it in no time!

* Tabular Interface
We put the collection of meta-geometries and the properties file `.dbf` into a `StructArray` for tablular representation.   
```julia
function structarray(shp::Handle, dbf::DBFTables.Table)
    dbf_cols = Tables.columntable(dbf)
    meta = collect(GB.meta(s) for s in shp.shapes)
    meta_cols = Tables.columntable(meta)
    return StructArray(Geometry = collect(GB.metafree(i) for i in shp.shapes); meta_cols..., dbf_cols...)
end
```
## ~~~<a href="https://github.com/visr/GeoJSONTables.jl/pull/3">GeoJSONTables.jl</a>~~~:
* Methods
Unlike `Shapefile.jl`, `GeoJSONTables.jl` has a semi-lazy `JSON` parsing. We have a direct `read()` method that directly reads the data into a StructArray `Table`.
The `read()` method has three major parts:
        
        1) The `JSON3` parsing:
```julia
    fc = JSON3.read(jsonbytes)
``` 
        2) Populating and constructing GeometryBasics features :

```julia
    fc = JSON3.read(jsonbytes)
``` 

* Missing values
The package now support efficient handling of `missing` data. This happens right during the construction of geometries via the `GeoJSONTables.geometry` method that accepts a `JSON3.Object`.   

* StructArrays

* Lower level interface
