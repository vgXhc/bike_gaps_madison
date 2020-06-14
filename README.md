# bike_gaps_madison
Resources for identifying and describing the top-10 gaps in the low-stress bike network in Madison (Wisconsin)

## Planned features
- interactive slippy map with layers for
  - [ ] residential density (American Community Survey)
  - [ ] job density (LODES)
  - [x] existing low stress bike network (MPO)
  - [x] households without car (American Community Survey)
  - [x] existing mode share (American Community Survey)
  - [x] household income/poverty (American Community Survey)
  - [ ] race/ethnicity
  - [ ] Aldermanic districts
  
## To do
- [ ]filter low-stress network to city only instead of county (improves performance)
  - [x] could download city boundary polygon and filter with `st_within()`
    - works but needs refinement; maybe using only outer boundary plus adding a 1-mile buffer?
  - [ ] manually define a filtering boundary box
    - will include a bunch of Middleton
- [ ] decide on whether to have map be Shiny app or embedded in Rmd doc
  - are there interactive features that could/should be implemented in a Shiny app?
    - Shiny app allows layer selection
      - currently performance issues with redrawing the low-stress network
        - can be resolved with `leafletProxy` (see [here]([https://stackoverflow.com/questions/37433569/changing-leaflet-map-according-to-input-without-redrawing))
- [ ] explore whether POI info can be included
- [ ] generate isochrones?
- [ ] think of ways to easily get the information from Madison Bikes top-10 exercise onto the map and keep it updated


  

