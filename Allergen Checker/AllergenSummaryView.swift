import SwiftData
import SwiftUI

struct AllergenSummaryView: View {
    @AppStorage("selectedAllergyProfileID") private var selectedProfileID = AllergyProfileOption.defaultID

    @Query(sort: \AllergyProfile.name) private var profiles: [AllergyProfile]
    @Query(sort: \Allergen.name) private var allergens: [Allergen]
    @State private var selectedLanguage: AllergenDisplayLanguage = .english

    private var selectedProfile: AllergyProfileOption {
        AllergyProfileSelection.selectedOption(storedID: selectedProfileID, profiles: profiles)
    }

    private var selectedProfileUUID: UUID? {
        selectedProfile.profileID
    }

    private var profileAllergens: [Allergen] {
        allergens.filter { $0.profileID == selectedProfileUUID }
    }

    private var pageTitle: String {
        if selectedProfile.profileID != nil {
            return selectedLanguage.allergiesTitle(for: selectedProfile.name)
        }

        return selectedLanguage.pageTitle
    }

    var body: some View {
        NavigationStack {
            Group {
                if profileAllergens.isEmpty {
                    ContentUnavailableView(
                        "No Allergens Configured",
                        systemImage: "person.text.rectangle",
                        description: Text("Add allergens for \(selectedProfile.name) in the Allergens tab to show them here.")
                    )
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            introCard
                            allergenCards
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle(pageTitle)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    AllergyProfilePicker(profiles: profiles, selectedProfileID: $selectedProfileID)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        ForEach(AllergenDisplayLanguage.allCases) { language in
                            Button {
                                selectedLanguage = language
                            } label: {
                                if selectedLanguage == language {
                                    Label(language.name, systemImage: "checkmark")
                                } else {
                                    Text(language.name)
                                }
                            }
                        }
                    } label: {
                        Label(selectedLanguage.name, systemImage: "globe")
                    }
                }
            }
        }
    }

    private var introCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(selectedLanguage.allergyListIntroduction, systemImage: "info.circle.fill")
                .font(.headline)

            if selectedLanguage == .english {
                Text("Translations are provided as a simple aid. Always confirm ingredients and allergen information yourself.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var allergenCards: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Language: \(selectedLanguage.name)")
                .font(.headline)

            ForEach(profileAllergens) { allergen in
                let translatedName = AllergenTranslationCatalog.translation(
                    for: allergen.name,
                    language: selectedLanguage
                )
                let displayName = selectedLanguage == .english ? allergen.name : translatedName ?? allergen.name

                VStack(alignment: .leading, spacing: 8) {
                    Text(displayName)
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    if selectedLanguage != .english {
                        Text(allergen.name)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    if !allergen.aliases.isEmpty {
                        Text("\(selectedLanguage.aliasesLabel) \(allergen.aliases.joined(separator: ", "))")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    if selectedLanguage != .english && translatedName == nil {
                        Label("Translation not available", systemImage: "exclamationmark.triangle")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                }
                .padding()
                .background(Color.accentColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 16))
                .accessibilityElement(children: .combine)
            }
        }
    }
}

enum AllergenDisplayLanguage: String, CaseIterable, Identifiable {
    case english
    case french
    case spanish
    case german
    case italian
    case portuguese
    case dutch
    case polish

    var id: String {
        rawValue
    }

    var name: String {
        switch self {
        case .english:
            "English"
        case .french:
            "French"
        case .spanish:
            "Spanish"
        case .german:
            "German"
        case .italian:
            "Italian"
        case .portuguese:
            "Portuguese"
        case .dutch:
            "Dutch"
        case .polish:
            "Polish"
        }
    }

    var allergyListIntroduction: String {
        switch self {
        case .english:
            "Here is a list of my allergies to show what I must avoid."
        case .french:
            "Voici la liste de mes allergies pour montrer ce que je dois éviter."
        case .spanish:
            "Aquí hay una lista de mis alergias para mostrar lo que debo evitar."
        case .german:
            "Hier ist eine Liste meiner Allergien, um zu zeigen, was ich vermeiden muss."
        case .italian:
            "Ecco un elenco delle mie allergie per mostrare cosa devo evitare."
        case .portuguese:
            "Aqui está uma lista das minhas alergias para mostrar o que devo evitar."
        case .dutch:
            "Hier is een lijst van mijn allergieën om te laten zien wat ik moet vermijden."
        case .polish:
            "Oto lista moich alergii, aby pokazać, czego muszę unikać."
        }
    }

    var pageTitle: String {
        switch self {
        case .english:
            "My Allergies"
        case .french:
            "Mes allergies"
        case .spanish:
            "Mis alergias"
        case .german:
            "Meine Allergien"
        case .italian:
            "Le mie allergie"
        case .portuguese:
            "As minhas alergias"
        case .dutch:
            "Mijn allergieën"
        case .polish:
            "Moje alergie"
        }
    }

    func allergiesTitle(for name: String) -> String {
        switch self {
        case .english:
            "\(name)'s Allergies"
        case .french:
            "Allergies de \(name)"
        case .spanish:
            "Alergias de \(name)"
        case .german:
            "\(name)s Allergien"
        case .italian:
            "Allergie di \(name)"
        case .portuguese:
            "Alergias de \(name)"
        case .dutch:
            "Allergieën van \(name)"
        case .polish:
            "Alergie: \(name)"
        }
    }

    var aliasesLabel: String {
        switch self {
        case .english:
            "Also listed as:"
        case .french:
            "Peut aussi etre indique comme :"
        case .spanish:
            "Tambien puede aparecer como:"
        case .german:
            "Kann auch aufgefuehrt sein als:"
        case .italian:
            "Puo comparire anche come:"
        case .portuguese:
            "Tambem pode aparecer como:"
        case .dutch:
            "Kan ook vermeld staan als:"
        case .polish:
            "Moze byc tez podane jako:"
        }
    }
}

enum AllergenTranslationCatalog {
    private typealias TranslationSet = [AllergenDisplayLanguage: String]
    private typealias TranslationSynonymSet = [AllergenDisplayLanguage: [String]]

    static func translation(for allergenName: String, language: AllergenDisplayLanguage) -> String? {
        translations(for: allergenName, language: language).first
    }

    static func translations(for allergenName: String, language: AllergenDisplayLanguage) -> [String] {
        let normalized = AllergenMatcher.normalizedSearchString(allergenName)
        guard !normalized.isEmpty else {
            return []
        }

        let primaryTranslation = translations[normalized]?[language].map { [$0] } ?? []
        let alternateTranslations = translationSynonyms[normalized]?[language] ?? []

        var uniqueTranslations: [String] = []
        var seenNormalizedTranslations = Set<String>()

        for translation in primaryTranslation + alternateTranslations {
            let normalizedTranslation = AllergenMatcher.normalizedSearchString(translation)
            guard !normalizedTranslation.isEmpty,
                  seenNormalizedTranslations.insert(normalizedTranslation).inserted else {
                continue
            }

            uniqueTranslations.append(translation)
        }

        return uniqueTranslations
    }

    private static let translations: [String: TranslationSet] = [
        "almonds": [.french: "Amandes", .spanish: "Almendras", .german: "Mandeln", .italian: "Mandorle", .portuguese: "Amendoas", .dutch: "Amandelen", .polish: "Migdały"],
        "apples": [.french: "Pommes", .spanish: "Manzanas", .german: "Aepfel", .italian: "Mele", .portuguese: "Macas", .dutch: "Appels", .polish: "Jabłka"],
        "avocado": [.french: "Avocat", .spanish: "Aguacate", .german: "Avocado", .italian: "Avocado", .portuguese: "Abacate", .dutch: "Avocado", .polish: "Awokado"],
        "bananas": [.french: "Bananes", .spanish: "Platanos", .german: "Bananen", .italian: "Banane", .portuguese: "Bananas", .dutch: "Bananen", .polish: "Banany"],
        "beans": [.french: "Haricots", .spanish: "Judias", .german: "Bohnen", .italian: "Fagioli", .portuguese: "Feijoes", .dutch: "Bonen", .polish: "Fasola"],
        "beef": [.french: "Boeuf", .spanish: "Ternera", .german: "Rindfleisch", .italian: "Manzo", .portuguese: "Carne de vaca", .dutch: "Rundvlees", .polish: "Wołowina"],
        "brazil nuts": [.french: "Noix du Bresil", .spanish: "Nueces de Brasil", .german: "Paranuesse", .italian: "Noci del Brasile", .portuguese: "Castanhas-do-para", .dutch: "Paranoten", .polish: "Orzechy brazylijskie"],
        "buckwheat": [.french: "Sarrasin", .spanish: "Trigo sarraceno", .german: "Buchweizen", .italian: "Grano saraceno", .portuguese: "Trigo-sarraceno", .dutch: "Boekweit", .polish: "Gryka"],
        "carrots": [.french: "Carottes", .spanish: "Zanahorias", .german: "Karotten", .italian: "Carote", .portuguese: "Cenouras", .dutch: "Wortelen", .polish: "Marchew"],
        "cashews": [.french: "Noix de cajou", .spanish: "Anacardos", .german: "Cashewnuesse", .italian: "Anacardi", .portuguese: "Cajus", .dutch: "Cashewnoten", .polish: "Orzechy nerkowca"],
        "celery": [.french: "Celeri", .spanish: "Apio", .german: "Sellerie", .italian: "Sedano", .portuguese: "Aipo", .dutch: "Selderij", .polish: "Seler"],
        "chickpeas": [.french: "Pois chiches", .spanish: "Garbanzos", .german: "Kichererbsen", .italian: "Ceci", .portuguese: "Grao-de-bico", .dutch: "Kikkererwten", .polish: "Ciecierzyca"],
        "citrus fruit": [.french: "Agrumes", .spanish: "Citricos", .german: "Zitrusfruechte", .italian: "Agrumi", .portuguese: "Citricos", .dutch: "Citrusvruchten", .polish: "Owoce cytrusowe"],
        "coconut": [.french: "Noix de coco", .spanish: "Coco", .german: "Kokosnuss", .italian: "Cocco", .portuguese: "Coco", .dutch: "Kokosnoot", .polish: "Kokos"],
        "cereals containing gluten": [.french: "Cereales contenant du gluten", .spanish: "Cereales con gluten", .german: "Glutenhaltiges Getreide", .italian: "Cereali contenenti glutine", .portuguese: "Cereais que contem gluten", .dutch: "Granen met gluten", .polish: "Zboza zawierajace gluten"],
        "corn": [.french: "Mais", .spanish: "Maiz", .german: "Mais", .italian: "Mais", .portuguese: "Milho", .dutch: "Mais", .polish: "Kukurydza"],
        "crustaceans": [.french: "Crustaces", .spanish: "Crustaceos", .german: "Krebstiere", .italian: "Crostacei", .portuguese: "Crustaceos", .dutch: "Schaaldieren", .polish: "Skorupiaki"],
        "eggs": [.french: "Oeufs", .spanish: "Huevos", .german: "Eier", .italian: "Uova", .portuguese: "Ovos", .dutch: "Eieren", .polish: "Jaja"],
        "fish": [.french: "Poisson", .spanish: "Pescado", .german: "Fisch", .italian: "Pesce", .portuguese: "Peixe", .dutch: "Vis", .polish: "Ryby"],
        "garlic": [.french: "Ail", .spanish: "Ajo", .german: "Knoblauch", .italian: "Aglio", .portuguese: "Alho", .dutch: "Knoflook", .polish: "Czosnek"],
        "hazelnuts": [.french: "Noisettes", .spanish: "Avellanas", .german: "Haselnuesse", .italian: "Nocciole", .portuguese: "Avelas", .dutch: "Hazelnoten", .polish: "Orzechy laskowe"],
        "kiwi": [.french: "Kiwi", .spanish: "Kiwi", .german: "Kiwi", .italian: "Kiwi", .portuguese: "Kiwi", .dutch: "Kiwi", .polish: "Kiwi"],
        "latex-associated foods": [.french: "Aliments associes au latex", .spanish: "Alimentos asociados al latex", .german: "Latex-assoziierte Lebensmittel", .italian: "Alimenti associati al lattice", .portuguese: "Alimentos associados ao latex", .dutch: "Latex-gerelateerde voedingsmiddelen", .polish: "Pokarmy zwiazane z lateksem"],
        "lentils": [.french: "Lentilles", .spanish: "Lentejas", .german: "Linsen", .italian: "Lenticchie", .portuguese: "Lentilhas", .dutch: "Linzen", .polish: "Soczewica"],
        "legumes and pulses": [.french: "Legumineuses", .spanish: "Legumbres", .german: "Hulsenfruechte", .italian: "Legumi", .portuguese: "Leguminosas", .dutch: "Peulvruchten", .polish: "Rosliny straczkowe"],
        "lupin": [.french: "Lupin", .spanish: "Altramuz", .german: "Lupine", .italian: "Lupino", .portuguese: "Tremoco", .dutch: "Lupine", .polish: "Lubin"],
        "macadamia nuts": [.french: "Noix de macadamia", .spanish: "Nueces de macadamia", .german: "Macadamianuesse", .italian: "Noci di macadamia", .portuguese: "Nozes de macadamia", .dutch: "Macadamianoten", .polish: "Orzechy makadamia"],
        "milk": [.french: "Lait", .spanish: "Leche", .german: "Milch", .italian: "Latte", .portuguese: "Leite", .dutch: "Melk", .polish: "Mleko"],
        "molluscs": [.french: "Mollusques", .spanish: "Moluscos", .german: "Weichtiere", .italian: "Molluschi", .portuguese: "Moluscos", .dutch: "Weekdieren", .polish: "Mieczaki"],
        "mustard": [.french: "Moutarde", .spanish: "Mostaza", .german: "Senf", .italian: "Senape", .portuguese: "Mostarda", .dutch: "Mosterd", .polish: "Gorczyca"],
        "oats": [.french: "Avoine", .spanish: "Avena", .german: "Hafer", .italian: "Avena", .portuguese: "Aveia", .dutch: "Haver", .polish: "Owies"],
        "onion": [.french: "Oignon", .spanish: "Cebolla", .german: "Zwiebel", .italian: "Cipolla", .portuguese: "Cebola", .dutch: "Ui", .polish: "Cebula"],
        "peas": [.french: "Pois", .spanish: "Guisantes", .german: "Erbsen", .italian: "Piselli", .portuguese: "Ervilhas", .dutch: "Erwten", .polish: "Groch"],
        "peanuts": [.french: "Arachides", .spanish: "Cacahuetes", .german: "Erdnuesse", .italian: "Arachidi", .portuguese: "Amendoins", .dutch: "Pindas", .polish: "Orzeszki ziemne"],
        "pecans": [.french: "Noix de pecan", .spanish: "Nueces pecanas", .german: "Pekannuesse", .italian: "Noci pecan", .portuguese: "Nozes-peca", .dutch: "Pecannoten", .polish: "Orzechy pekan"],
        "pine nuts": [.french: "Pignons de pin", .spanish: "Pinones", .german: "Pinienkerne", .italian: "Pinoli", .portuguese: "Pinhoes", .dutch: "Pijnboompitten", .polish: "Orzeszki piniowe"],
        "pistachios": [.french: "Pistaches", .spanish: "Pistachos", .german: "Pistazien", .italian: "Pistacchi", .portuguese: "Pistacios", .dutch: "Pistachenoten", .polish: "Pistacje"],
        "pork": [.french: "Porc", .spanish: "Cerdo", .german: "Schweinefleisch", .italian: "Maiale", .portuguese: "Porco", .dutch: "Varkensvlees", .polish: "Wieprzowina"],
        "potatoes": [.french: "Pommes de terre", .spanish: "Patatas", .german: "Kartoffeln", .italian: "Patate", .portuguese: "Batatas", .dutch: "Aardappelen", .polish: "Ziemniaki"],
        "rice": [.french: "Riz", .spanish: "Arroz", .german: "Reis", .italian: "Riso", .portuguese: "Arroz", .dutch: "Rijst", .polish: "Ryz"],
        "seeds": [.french: "Graines", .spanish: "Semillas", .german: "Samen", .italian: "Semi", .portuguese: "Sementes", .dutch: "Zaden", .polish: "Nasiona"],
        "sesame": [.french: "Sesame", .spanish: "Sesamo", .german: "Sesam", .italian: "Sesamo", .portuguese: "Sesamo", .dutch: "Sesam", .polish: "Sezam"],
        "shellfish": [.french: "Fruits de mer", .spanish: "Marisco", .german: "Schalentiere", .italian: "Frutti di mare", .portuguese: "Marisco", .dutch: "Schaal- en schelpdieren", .polish: "Owoce morza"],
        "soya": [.french: "Soja", .spanish: "Soja", .german: "Soja", .italian: "Soia", .portuguese: "Soja", .dutch: "Soja", .polish: "Soja"],
        "strawberries": [.french: "Fraises", .spanish: "Fresas", .german: "Erdbeeren", .italian: "Fragole", .portuguese: "Morangos", .dutch: "Aardbeien", .polish: "Truskawki"],
        "sulphur dioxide and sulphites": [.french: "Dioxyde de soufre et sulfites", .spanish: "Dioxido de azufre y sulfitos", .german: "Schwefeldioxid und Sulfite", .italian: "Anidride solforosa e solfiti", .portuguese: "Dioxido de enxofre e sulfitos", .dutch: "Zwaveldioxide en sulfieten", .polish: "Dwutlenek siarki i siarczyny"],
        "sunflower": [.french: "Tournesol", .spanish: "Girasol", .german: "Sonnenblume", .italian: "Girasole", .portuguese: "Girassol", .dutch: "Zonnebloem", .polish: "Slonecznik"],
        "tomatoes": [.french: "Tomates", .spanish: "Tomates", .german: "Tomaten", .italian: "Pomodori", .portuguese: "Tomates", .dutch: "Tomaten", .polish: "Pomidory"],
        "tree nuts": [.french: "Fruits a coque", .spanish: "Frutos de cascara", .german: "Schalenfruechte", .italian: "Frutta a guscio", .portuguese: "Frutos de casca rija", .dutch: "Noten", .polish: "Orzechy drzewne"],
        "walnuts": [.french: "Noix", .spanish: "Nueces", .german: "Walnuesse", .italian: "Noci", .portuguese: "Nozes", .dutch: "Walnoten", .polish: "Orzechy wloskie"],
        "wheat": [.french: "Ble", .spanish: "Trigo", .german: "Weizen", .italian: "Grano", .portuguese: "Trigo", .dutch: "Tarwe", .polish: "Pszenica"],
        "sulphites e220 e228": [.french: "Sulfites (E220-E228)", .spanish: "Sulfitos (E220-E228)", .german: "Sulfite (E220-E228)", .italian: "Solfiti (E220-E228)", .portuguese: "Sulfitos (E220-E228)", .dutch: "Sulfieten (E220-E228)", .polish: "Siarczyny (E220-E228)"],
        "lecithins e322": [.french: "Lecithines (E322)", .spanish: "Lecitinas (E322)", .german: "Lecithine (E322)", .italian: "Lecitine (E322)", .portuguese: "Lecitinas (E322)", .dutch: "Lecithinen (E322)", .polish: "Lecytyny (E322)"],
        "gelatine e441": [.french: "Gelatine (E441)", .spanish: "Gelatina (E441)", .german: "Gelatine (E441)", .italian: "Gelatina (E441)", .portuguese: "Gelatina (E441)", .dutch: "Gelatine (E441)", .polish: "Zelatyna (E441)"],
        "cochineal and carmine e120": [.french: "Cochenille et carmin (E120)", .spanish: "Cochinilla y carmin (E120)", .german: "Cochenille und Karmin (E120)", .italian: "Cocciniglia e carminio (E120)", .portuguese: "Cochonilha e carmim (E120)", .dutch: "Cochenille en karmijn (E120)", .polish: "Koszenila i karmin (E120)"],
        "carotenes e160a": [.french: "Carotenes (E160a)", .spanish: "Carotenos (E160a)", .german: "Carotine (E160a)", .italian: "Caroteni (E160a)", .portuguese: "Carotenos (E160a)", .dutch: "Carotenen (E160a)", .polish: "Karoteny (E160a)"],
        "annatto e160b": [.french: "Annatto (E160b)", .spanish: "Achiote (E160b)", .german: "Annatto (E160b)", .italian: "Annatto (E160b)", .portuguese: "Urucum (E160b)", .dutch: "Annatto (E160b)", .polish: "Annato (E160b)"],
        "glutamates and msg e620 e625": [.french: "Glutamates et MSG (E620-E625)", .spanish: "Glutamatos y MSG (E620-E625)", .german: "Glutamate und MSG (E620-E625)", .italian: "Glutammati e MSG (E620-E625)", .portuguese: "Glutamatos e MSG (E620-E625)", .dutch: "Glutamaten en MSG (E620-E625)", .polish: "Glutaminiany i MSG (E620-E625)"]
    ]

    private static let translationSynonyms: [String: TranslationSynonymSet] = [
        "peanuts": [
            .french: ["Cacahuetes"]
        ]
    ]
}

#Preview {
    AllergenSummaryView()
        .modelContainer(for: [AllergyProfile.self, Allergen.self], inMemory: true)
}
