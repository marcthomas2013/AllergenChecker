import Foundation

struct CommonAllergen: Identifiable, Hashable {
    let name: String
    let aliases: [String]

    var id: String {
        name
    }
}

enum CommonAllergenCatalog {
    static let allergens: [CommonAllergen] = [
        CommonAllergen(name: "Almonds", aliases: ["almond"]),
        CommonAllergen(name: "Apples", aliases: ["apple"]),
        CommonAllergen(name: "Avocado", aliases: ["avocados"]),
        CommonAllergen(name: "Bananas", aliases: ["banana"]),
        CommonAllergen(name: "Beans", aliases: ["bean", "black bean", "broad bean", "kidney bean", "navy bean", "pinto bean"]),
        CommonAllergen(name: "Beef", aliases: ["gelatin", "gelatine"]),
        CommonAllergen(name: "Brazil nuts", aliases: ["brazil nut"]),
        CommonAllergen(name: "Buckwheat", aliases: ["soba"]),
        CommonAllergen(name: "Carrots", aliases: ["carrot"]),
        CommonAllergen(name: "Cashews", aliases: ["cashew"]),
        CommonAllergen(name: "Celery", aliases: ["celeriac"]),
        CommonAllergen(name: "Chickpeas", aliases: ["chickpea", "besan", "chana", "gram flour", "hummus"]),
        CommonAllergen(name: "Citrus fruit", aliases: ["grapefruit", "lemon", "lime", "orange"]),
        CommonAllergen(name: "Coconut", aliases: ["coconuts"]),
        CommonAllergen(name: "Cereals containing gluten", aliases: ["barley", "oats", "rye", "spelt", "wheat"]),
        CommonAllergen(name: "Corn", aliases: ["maize", "cornflour", "corn flour", "corn starch", "cornstarch"]),
        CommonAllergen(name: "Crustaceans", aliases: ["crab", "crayfish", "lobster", "prawn", "shrimp"]),
        CommonAllergen(name: "Eggs", aliases: ["egg", "albumen"]),
        CommonAllergen(name: "Fish", aliases: ["anchovy", "cod", "haddock", "salmon", "tuna"]),
        CommonAllergen(name: "Garlic", aliases: ["garlic powder"]),
        CommonAllergen(name: "Hazelnuts", aliases: ["hazelnut"]),
        CommonAllergen(name: "Kiwi", aliases: ["kiwifruit"]),
        CommonAllergen(name: "Latex-associated foods", aliases: ["avocado", "banana", "chestnut", "kiwi"]),
        CommonAllergen(name: "Lentils", aliases: ["lentil", "red lentil", "green lentil"]),
        CommonAllergen(name: "Legumes and pulses", aliases: ["bean", "beans", "chickpea", "chickpeas", "lentil", "lentils", "pea", "peas", "pulse", "pulses"]),
        CommonAllergen(name: "Lupin", aliases: ["lupine"]),
        CommonAllergen(name: "Macadamia nuts", aliases: ["macadamia", "macadamia nut"]),
        CommonAllergen(name: "Milk", aliases: ["casein", "lactose", "whey"]),
        CommonAllergen(name: "Molluscs", aliases: ["clam", "mussel", "oyster", "scallop", "squid"]),
        CommonAllergen(name: "Mustard", aliases: ["mustard seed"]),
        CommonAllergen(name: "Oats", aliases: ["oat", "oatmeal"]),
        CommonAllergen(name: "Onion", aliases: ["onions", "onion powder"]),
        CommonAllergen(name: "Peas", aliases: ["pea", "pea protein"]),
        CommonAllergen(name: "Peanuts", aliases: ["peanut", "groundnut"]),
        CommonAllergen(name: "Pecans", aliases: ["pecan"]),
        CommonAllergen(name: "Pine nuts", aliases: ["pine nut"]),
        CommonAllergen(name: "Pistachios", aliases: ["pistachio"]),
        CommonAllergen(name: "Pork", aliases: ["porcine", "pork gelatin", "pork gelatine"]),
        CommonAllergen(name: "Potatoes", aliases: ["potato", "potato starch"]),
        CommonAllergen(name: "Rice", aliases: ["rice flour", "rice starch"]),
        CommonAllergen(name: "Seeds", aliases: ["chia", "flax", "linseed", "poppy seed", "pumpkin seed", "sunflower seed"]),
        CommonAllergen(name: "Sesame", aliases: ["sesame seed", "tahini"]),
        CommonAllergen(name: "Shellfish", aliases: ["crustacean", "crustaceans", "mollusc", "molluscs"]),
        CommonAllergen(name: "Soya", aliases: ["soy", "soybean"]),
        CommonAllergen(name: "Strawberries", aliases: ["strawberry"]),
        CommonAllergen(name: "Sulphur dioxide and sulphites", aliases: ["sulfites", "sulphites"]),
        CommonAllergen(name: "Sunflower", aliases: ["sunflower seed", "sunflower oil"]),
        CommonAllergen(name: "Tomatoes", aliases: ["tomato"]),
        CommonAllergen(name: "Tree nuts", aliases: ["almond", "brazil nut", "cashew", "hazelnut", "macadamia", "pecan", "pistachio", "walnut"]),
        CommonAllergen(name: "Walnuts", aliases: ["walnut"]),
        CommonAllergen(name: "Wheat", aliases: ["bran", "bulgur", "couscous", "durum", "semolina"])
    ]

    static let eNumberIngredients: [CommonAllergen] = [
        CommonAllergen(name: "Sulphites (E220-E228)", aliases: ["sulphur dioxide", "sulfur dioxide", "sulphite", "sulphites", "sulfite", "sulfites"] + eNumberAliases("E220", "E221", "E222", "E223", "E224", "E225", "E226", "E227", "E228")),
        CommonAllergen(name: "Lecithins (E322)", aliases: ["lecithin", "egg lecithin", "soya lecithin", "soy lecithin", "sunflower lecithin"] + eNumberAliases("E322")),
        CommonAllergen(name: "Gelatine (E441)", aliases: ["gelatin", "gelatine", "beef gelatine", "fish gelatine", "pork gelatine"] + eNumberAliases("E441")),
        CommonAllergen(name: "Cochineal and carmine (E120)", aliases: ["cochineal", "carmine", "carminic acid"] + eNumberAliases("E120")),
        CommonAllergen(name: "Carotenes (E160a)", aliases: ["carotene", "carotenes", "alpha-carotene", "beta-carotene"] + eNumberAliases("E160a")),
        CommonAllergen(name: "Annatto (E160b)", aliases: ["annatto", "bixin", "norbixin"] + eNumberAliases("E160b")),
        CommonAllergen(name: "Paprika extract (E160c)", aliases: ["paprika", "paprika extract", "capsanthin", "capsorubin"] + eNumberAliases("E160c")),
        CommonAllergen(name: "Lycopene (E160d)", aliases: ["lycopene"] + eNumberAliases("E160d")),
        CommonAllergen(name: "Beta-apo-carotenals (E160e-E160f)", aliases: ["beta-apo-8'-carotenal", "ethyl ester of beta-apo-8'-carotenoic acid"] + eNumberAliases("E160e", "E160f")),
        CommonAllergen(name: "Tocopherols (E306-E309)", aliases: ["tocopherol", "tocopherols", "vitamin e"] + eNumberAliases("E306", "E307", "E308", "E309")),
        CommonAllergen(name: "Azo and warning food colours", aliases: ["tartrazine", "quinoline yellow", "sunset yellow", "carmoisine", "azorubine", "ponceau 4r", "allura red"] + eNumberAliases("E102", "E104", "E110", "E122", "E124", "E129")),
        CommonAllergen(name: "Benzoates (E210-E219)", aliases: ["benzoic acid", "benzoate", "benzoates", "sodium benzoate", "potassium benzoate", "calcium benzoate"] + eNumberAliases("E210", "E211", "E212", "E213", "E214", "E215", "E216", "E217", "E218", "E219")),
        CommonAllergen(name: "Sorbates (E200-E203)", aliases: ["sorbic acid", "sorbate", "sorbates", "potassium sorbate", "calcium sorbate"] + eNumberAliases("E200", "E201", "E202", "E203")),
        CommonAllergen(name: "Nitrates and nitrites (E249-E252)", aliases: ["nitrite", "nitrites", "nitrate", "nitrates", "potassium nitrite", "sodium nitrite", "sodium nitrate", "potassium nitrate"] + eNumberAliases("E249", "E250", "E251", "E252")),
        CommonAllergen(name: "Glutamates and MSG (E620-E625)", aliases: ["glutamic acid", "glutamate", "glutamates", "monosodium glutamate", "msg"] + eNumberAliases("E620", "E621", "E622", "E623", "E624", "E625")),
        CommonAllergen(name: "Modified starches (E1404-E1452)", aliases: ["modified starch", "oxidised starch", "monostarch phosphate", "distarch phosphate", "phosphated distarch phosphate", "acetylated distarch phosphate", "hydroxypropyl starch", "hydroxypropyl distarch phosphate", "starch sodium octenyl succinate", "acetylated oxidised starch"] + eNumberAliases("E1404", "E1410", "E1412", "E1413", "E1414", "E1420", "E1422", "E1440", "E1442", "E1450", "E1451", "E1452")),
        CommonAllergen(name: "Guar gum (E412)", aliases: ["guar", "guar gum"] + eNumberAliases("E412")),
        CommonAllergen(name: "Locust bean gum (E410)", aliases: ["carob gum", "locust bean gum"] + eNumberAliases("E410")),
        CommonAllergen(name: "Acacia gum (E414)", aliases: ["acacia", "gum arabic", "acacia gum"] + eNumberAliases("E414")),
        CommonAllergen(name: "Carrageenan (E407)", aliases: ["carrageenan", "carrageenin"] + eNumberAliases("E407")),
        CommonAllergen(name: "Lysozyme (E1105)", aliases: ["lysozyme", "egg lysozyme"] + eNumberAliases("E1105"))
    ]

    private static func eNumberAliases(_ codes: String...) -> [String] {
        codes.flatMap { code in
            [code, code.replacingOccurrences(of: "E", with: "E ")]
        }
    }
}
