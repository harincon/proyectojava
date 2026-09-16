import { useState } from "react";
import Logo from "../components/Logo";
import { Btn, Badge, Card, Input, Select, Pagination } from "../components/ui";

const ALL_PROPS = [
  { id: 1, title: "Apartamento moderno en Chapinero", city: "Bogotá", neighborhood: "Chapinero Alto", price: "$ 520.000.000", modalidad: "venta", tipo: "Apartamento", beds: 3, baths: 2, area: 85, img: "https://images.unsplash.com/photo-1754999809963-79a41e8fb648?w=600&h=400&fit=crop&auto=format", inmobiliaria: "Alfa Inmobiliaria", estado: "Disponible" },
  { id: 2, title: "Casa familiar con jardín", city: "Medellín", neighborhood: "El Poblado", price: "$ 4.200.000/mes", modalidad: "arriendo", tipo: "Casa", beds: 4, baths: 3, area: 180, img: "https://images.unsplash.com/photo-1786462543687-26614deb2d6f?w=600&h=400&fit=crop&auto=format", inmobiliaria: "Grupo Habitat", estado: "Disponible" },
  { id: 3, title: "Penthouse con vista panorámica", city: "Cali", neighborhood: "Ciudad Jardín", price: "$ 1.200.000.000", modalidad: "venta", tipo: "Penthouse", beds: 5, baths: 4, area: 320, img: "https://images.unsplash.com/photo-1782803432396-e168aa0e54a1?w=600&h=400&fit=crop&auto=format", inmobiliaria: "Luxe Properties", estado: "Disponible" },
  { id: 4, title: "Oficina corporativa central", city: "Bogotá", neighborhood: "Salitre", price: "$ 6.800.000/mes", modalidad: "arriendo", tipo: "Oficina", beds: 0, baths: 2, area: 120, img: "https://images.unsplash.com/photo-1780147343308-7ede77816ee6?w=600&h=400&fit=crop&auto=format", inmobiliaria: "Comercial Bogotá", estado: "Disponible" },
  { id: 5, title: "Local comercial esquinero", city: "Barranquilla", neighborhood: "El Prado", price: "$ 890.000.000", modalidad: "venta", tipo: "Local", beds: 0, baths: 1, area: 65, img: "https://images.unsplash.com/photo-1789132782754-b89fe6c5c774?w=600&h=400&fit=crop&auto=format", inmobiliaria: "Costa Finca Raíz", estado: "Disponible" },
  { id: 6, title: "Apartaestudio amoblado Zona Rosa", city: "Bogotá", neighborhood: "Zona Rosa", price: "$ 2.100.000/mes", modalidad: "arriendo", tipo: "Apartaestudio", beds: 1, baths: 1, area: 42, img: "https://images.unsplash.com/photo-1757924461488-ef9ad0670978?w=600&h=400&fit=crop&auto=format", inmobiliaria: "Alfa Inmobiliaria", estado: "Disponible" },
  { id: 7, title: "Casa campestre con piscina", city: "Medellín", neighborhood: "Envigado", price: "$ 2.400.000.000", modalidad: "venta", tipo: "Casa", beds: 6, baths: 5, area: 450, img: "https://images.unsplash.com/photo-1786051387804-9b9333c28bcb?w=600&h=400&fit=crop&auto=format", inmobiliaria: "Grupo Habitat", estado: "Negociando" },
  { id: 8, title: "Bodega industrial zona norte", city: "Bogotá", neighborhood: "Fontibón", price: "$ 12.500.000/mes", modalidad: "arriendo", tipo: "Bodega", beds: 0, baths: 2, area: 800, img: "https://images.unsplash.com/photo-1515263487990-61b07816b324?w=600&h=400&fit=crop&auto=format", inmobiliaria: "Industrial Col", estado: "Disponible" },
  { id: 9, title: "Apartamento frente al mar", city: "Cartagena", neighborhood: "Bocagrande", price: "$ 780.000.000", modalidad: "venta", tipo: "Apartamento", beds: 3, baths: 2, area: 95, img: "https://images.unsplash.com/photo-1565953522043-baea26b83b7e?w=600&h=400&fit=crop&auto=format", inmobiliaria: "Costa Finca Raíz", estado: "Disponible" },
];

interface CatalogProps {
  onNavigate: (view: string, extra?: object) => void;
}

export default function Catalog({ onNavigate }: CatalogProps) {
  const [modalidad, setModalidad] = useState("");
  const [tipo, setTipo] = useState("");
  const [ciudad, setCiudad] = useState("");
  const [precioMax, setPrecioMax] = useState("");
  const [habitaciones, setHabitaciones] = useState("");
  const [page, setPage] = useState(1);
  const [filtersOpen, setFiltersOpen] = useState(false);

  const filtered = ALL_PROPS.filter(p => {
    if (modalidad && p.modalidad !== modalidad.toLowerCase()) return false;
    if (tipo && p.tipo !== tipo) return false;
    if (ciudad && p.city !== ciudad) return false;
    if (habitaciones && p.beds < parseInt(habitaciones)) return false;
    return true;
  });

  return (
    <div className="min-h-screen bg-[#F7F2E8]">
      {/* Header */}
      <header className="bg-[#243B32] sticky top-0 z-40">
        <div className="max-w-[1440px] mx-auto px-6 lg:px-12 h-16 flex items-center justify-between">
          <button onClick={() => onNavigate("home")}><Logo size="md" variant="light" /></button>
          <nav className="hidden md:flex items-center gap-7">
            <button onClick={() => onNavigate("catalog")} className="text-[#F7F2E8] text-sm font-semibold border-b-2 border-[#C96E4B] pb-0.5">Propiedades</button>
            <button className="text-[#E8D8C4]/70 hover:text-[#F7F2E8] text-sm font-medium transition-colors">Inmobiliarias</button>
          </nav>
          <div className="flex items-center gap-3">
            <Btn variant="ghost" size="sm" onClick={() => onNavigate("auth")} className="text-[#E8D8C4]/70 hover:text-[#F7F2E8] hover:bg-white/10">
              Iniciar sesión
            </Btn>
            <Btn size="sm" onClick={() => onNavigate("auth")}>Publicar</Btn>
          </div>
        </div>
      </header>

      <div className="max-w-[1440px] mx-auto px-6 lg:px-12 py-8">
        {/* Top filters */}
        <div className="flex flex-wrap items-center gap-3 mb-6">
          <h1 className="font-display text-2xl font-semibold text-[#243B32] mr-4">Propiedades en Colombia</h1>
          <div className="flex gap-2">
            {["Venta", "Arriendo"].map(m => (
              <button
                key={m}
                onClick={() => setModalidad(modalidad === m.toLowerCase() ? "" : m.toLowerCase())}
                className={`px-4 py-2 rounded-full text-sm font-medium border transition-all ${modalidad === m.toLowerCase() ? "bg-[#243B32] text-[#F7F2E8] border-[#243B32]" : "bg-white border-[#ddd6c8] text-[#252525] hover:border-[#83946A]"}`}
              >
                {m}
              </button>
            ))}
          </div>
          <button
            onClick={() => setFiltersOpen(!filtersOpen)}
            className="ml-auto flex items-center gap-2 px-4 py-2 rounded-full border border-[#ddd6c8] bg-white text-sm font-medium hover:border-[#83946A] transition-colors"
          >
            ⚙ Filtros {filtersOpen ? "▲" : "▼"}
          </button>
          <span className="text-sm text-[#6b7280]">{filtered.length} resultados</span>
        </div>

        <div className="flex gap-8">
          {/* Sidebar filters */}
          <aside className={`w-64 shrink-0 ${filtersOpen ? "block" : "hidden lg:block"}`}>
            <div className="bg-[#E8D8C4] rounded-2xl p-5 space-y-5 sticky top-24">
              <h2 className="font-display text-lg font-semibold text-[#243B32]">Filtros</h2>

              <Select label="Ciudad" value={ciudad} onChange={e => setCiudad(e.target.value)}>
                <option value="">Todas</option>
                <option>Bogotá</option>
                <option>Medellín</option>
                <option>Cali</option>
                <option>Barranquilla</option>
                <option>Cartagena</option>
              </Select>

              <Select label="Tipo de inmueble" value={tipo} onChange={e => setTipo(e.target.value)}>
                <option value="">Todos</option>
                <option>Apartamento</option>
                <option>Casa</option>
                <option>Oficina</option>
                <option>Local</option>
                <option>Bodega</option>
                <option>Penthouse</option>
                <option>Apartaestudio</option>
              </Select>

              <div>
                <label className="text-sm font-medium text-[#252525] block mb-1.5">Precio máximo</label>
                <Input
                  placeholder="Ej: 500.000.000"
                  value={precioMax}
                  onChange={e => setPrecioMax(e.target.value)}
                />
              </div>

              <Select label="Habitaciones mínimas" value={habitaciones} onChange={e => setHabitaciones(e.target.value)}>
                <option value="">Cualquiera</option>
                <option value="1">1+</option>
                <option value="2">2+</option>
                <option value="3">3+</option>
                <option value="4">4+</option>
              </Select>

              <div>
                <label className="text-sm font-medium text-[#252525] block mb-3">Características</label>
                <div className="space-y-2">
                  {["Piscina", "Parqueadero", "Gym", "Terraza", "Ascensor", "Amoblado"].map(c => (
                    <label key={c} className="flex items-center gap-2.5 cursor-pointer group">
                      <input type="checkbox" className="accent-[#C96E4B] w-4 h-4 rounded" />
                      <span className="text-sm text-[#252525] group-hover:text-[#243B32]">{c}</span>
                    </label>
                  ))}
                </div>
              </div>

              <Btn variant="ghost" size="sm" className="w-full text-[#6b7280]" onClick={() => { setModalidad(""); setTipo(""); setCiudad(""); setHabitaciones(""); setPrecioMax(""); }}>
                Limpiar filtros
              </Btn>
            </div>
          </aside>

          {/* Property grid */}
          <main className="flex-1 min-w-0">
            <div className="flex items-center justify-between mb-5">
              <p className="text-sm text-[#6b7280]">Mostrando <strong>{filtered.length}</strong> propiedades</p>
              <select className="text-sm border border-[#ddd6c8] rounded-lg px-3 py-2 bg-white focus:outline-none focus:border-[#C96E4B]">
                <option>Más relevantes</option>
                <option>Menor precio</option>
                <option>Mayor precio</option>
                <option>Más recientes</option>
              </select>
            </div>

            {filtered.length === 0 ? (
              <div className="flex flex-col items-center justify-center py-20 text-center">
                <div className="w-16 h-16 rounded-2xl bg-[#E8D8C4] flex items-center justify-center text-3xl mb-4">🏠</div>
                <h3 className="font-display text-xl font-semibold text-[#243B32] mb-2">Sin resultados</h3>
                <p className="text-[#6b7280] text-sm max-w-xs">No encontramos propiedades con estos filtros. Intenta ampliar tu búsqueda.</p>
                <Btn className="mt-6" variant="outline" onClick={() => { setModalidad(""); setTipo(""); setCiudad(""); }}>Limpiar filtros</Btn>
              </div>
            ) : (
              <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-5">
                {filtered.map(p => (
                  <CatalogCard key={p.id} property={p} onNavigate={onNavigate} />
                ))}
              </div>
            )}

            <div className="mt-10 flex justify-center">
              <Pagination current={page} total={3} onChange={setPage} />
            </div>
          </main>
        </div>
      </div>
    </div>
  );
}

function CatalogCard({ property: p, onNavigate }: { property: typeof ALL_PROPS[0]; onNavigate: (v: string, e?: object) => void }) {
  const [liked, setLiked] = useState(false);
  return (
    <Card
      className="overflow-hidden group cursor-pointer hover:shadow-md transition-all hover:-translate-y-0.5"
      onClick={() => onNavigate("detail", { id: p.id })}
    >
      <div className="relative h-48 bg-[#E8D8C4] overflow-hidden">
        <img src={p.img} alt={p.title} className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500" />
        <div className="absolute top-3 left-3 flex gap-1.5">
          <Badge label={p.modalidad === "venta" ? "Venta" : "Arriendo"} variant={p.modalidad === "venta" ? "venta" : "arriendo"} />
          <Badge label={p.estado} variant={p.estado === "Disponible" ? "success" : "warning"} />
        </div>
        <button
          className={`absolute top-3 right-3 w-8 h-8 rounded-full flex items-center justify-center text-sm transition-all ${liked ? "bg-[#C96E4B] text-white" : "bg-white/90 text-[#6b7280] hover:text-[#C96E4B]"}`}
          onClick={e => { e.stopPropagation(); setLiked(!liked); }}
        >
          {liked ? "♥" : "♡"}
        </button>
      </div>
      <div className="p-4">
        <p className="font-display text-lg font-semibold text-[#C96E4B]">{p.price}</p>
        <h3 className="text-sm font-medium text-[#252525] mt-0.5 leading-snug line-clamp-2">{p.title}</h3>
        <p className="text-xs text-[#83946A] mt-1">📍 {p.neighborhood}, {p.city}</p>
        <p className="text-xs text-[#6b7280] mt-0.5">{p.inmobiliaria}</p>
        <div className="flex items-center gap-3 text-xs text-[#6b7280] border-t border-[#ddd6c8] mt-3 pt-3">
          {p.beds > 0 && <span>🛏 {p.beds}</span>}
          <span>🚿 {p.baths}</span>
          <span>📐 {p.area}m²</span>
          <span className="ml-auto">
            <Btn size="sm" variant="outline" onClick={e => { e.stopPropagation(); onNavigate("detail", { id: p.id }); }} className="text-xs px-3 py-1.5">
              Ver detalle
            </Btn>
          </span>
        </div>
      </div>
    </Card>
  );
}
