import { useState } from "react";
import Logo from "../components/Logo";
import { Btn, Badge, Card, StatCard, Modal, Alert } from "../components/ui";

type Tab = "usuarios" | "inmobiliarias" | "ciudades" | "tipos" | "caracteristicas";

const USUARIOS = [
  { id: 1, nombre: "Laura Rodríguez", email: "laura@ejemplo.com", rol: "Cliente", ciudad: "Bogotá", estado: "Activo", registro: "12 ago 2025" },
  { id: 2, nombre: "Carlos Rueda", email: "crueda@alfainm.co", rol: "Inmobiliaria", ciudad: "Bogotá", estado: "Activo", registro: "5 ene 2024" },
  { id: 3, nombre: "Andrés Martínez", email: "andres@gmail.com", rol: "Cliente", ciudad: "Medellín", estado: "Activo", registro: "3 sep 2026" },
  { id: 4, nombre: "Sofía Herrera", email: "sofiah@luxe.co", rol: "Inmobiliaria", ciudad: "Cali", estado: "Inactivo", registro: "20 mar 2023" },
  { id: 5, nombre: "Pedro Jiménez", email: "pedro.j@hotmail.com", rol: "Cliente", ciudad: "Barranquilla", estado: "Activo", registro: "1 jul 2025" },
];

const INMOBILIARIAS = [
  { id: 1, nombre: "Alfa Inmobiliaria", ciudad: "Bogotá", plan: "Pro", propiedades: 12, estado: "Activa", contacto: "crueda@alfainm.co" },
  { id: 2, nombre: "Grupo Habitat", ciudad: "Medellín", plan: "Pro", propiedades: 28, estado: "Activa", contacto: "info@grupohabitat.co" },
  { id: 3, nombre: "Luxe Properties", ciudad: "Cali", plan: "Básico", propiedades: 5, estado: "Inactiva", contacto: "sofiah@luxe.co" },
  { id: 4, nombre: "Costa Finca Raíz", ciudad: "Barranquilla", plan: "Básico", propiedades: 9, estado: "Activa", contacto: "ventas@costafr.co" },
];

interface AdminProps { onNavigate: (view: string, extra?: object) => void; }

export default function AdminPanel({ onNavigate }: AdminProps) {
  const [tab, setTab] = useState<Tab>("usuarios");

  const sidebarLinks: { id: Tab; label: string; icon: string }[] = [
    { id: "usuarios", label: "Usuarios", icon: "👥" },
    { id: "inmobiliarias", label: "Inmobiliarias", icon: "🏢" },
    { id: "ciudades", label: "Ciudades", icon: "🗺" },
    { id: "tipos", label: "Tipos de inmueble", icon: "🏠" },
    { id: "caracteristicas", label: "Características", icon: "⚙" },
  ];

  return (
    <div className="min-h-screen bg-[#F7F2E8] flex flex-col">
      <header className="bg-[#243B32] h-16 flex items-center px-6 justify-between sticky top-0 z-40">
        <button onClick={() => onNavigate("home")}><Logo size="md" variant="light" /></button>
        <div className="flex items-center gap-3">
          <Badge label="Administrador" variant="warning" />
          <div className="w-8 h-8 rounded-full bg-[#83946A] flex items-center justify-center text-white text-sm font-bold">A</div>
          <Btn variant="ghost" size="sm" onClick={() => onNavigate("home")} className="text-[#E8D8C4]/70 hover:bg-white/10 text-xs">Salir</Btn>
        </div>
      </header>

      <div className="flex flex-1 max-w-[1440px] mx-auto w-full">
        <aside className="w-64 shrink-0 bg-white border-r border-[#ddd6c8] hidden md:flex flex-col pt-8 pb-6 px-4">
          <div className="mb-8 px-3">
            <p className="font-semibold text-[#252525]">Panel de administración</p>
            <p className="text-xs text-[#6b7280] mt-0.5">admin@habita.co</p>
          </div>
          <nav className="space-y-1 flex-1">
            {sidebarLinks.map(l => (
              <button
                key={l.id}
                onClick={() => setTab(l.id)}
                className={`w-full flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-medium transition-all text-left ${tab === l.id ? "bg-[#243B32] text-[#F7F2E8]" : "text-[#6b7280] hover:bg-[#F7F2E8] hover:text-[#252525]"}`}
              >
                <span>{l.icon}</span> {l.label}
              </button>
            ))}
          </nav>
        </aside>

        <main className="flex-1 min-w-0 p-6 lg:p-8">
          {/* Stats row */}
          <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
            <StatCard label="Total usuarios" value="1.248" icon="👥" trend="+24 este mes" />
            <StatCard label="Inmobiliarias" value="38" icon="🏢" trend="+3 este mes" />
            <StatCard label="Propiedades activas" value="12.400" icon="🏠" />
            <StatCard label="Ciudades registradas" value="28" icon="🗺" />
          </div>

          {tab === "usuarios" && <UsuariosTab />}
          {tab === "inmobiliarias" && <InmobiliariasTab />}
          {tab === "ciudades" && <CatalogAdmin title="Ciudades" items={["Bogotá", "Medellín", "Cali", "Barranquilla", "Cartagena", "Bucaramanga", "Cúcuta", "Manizales", "Pereira", "Santa Marta"]} placeholder="Nueva ciudad" />}
          {tab === "tipos" && <CatalogAdmin title="Tipos de inmueble" items={["Apartamento", "Casa", "Oficina", "Local comercial", "Bodega", "Lote", "Penthouse", "Apartaestudio", "Finca"]} placeholder="Nuevo tipo" />}
          {tab === "caracteristicas" && <CatalogAdmin title="Características" items={["Parqueadero", "Piscina", "Gimnasio", "Terraza", "Ascensor", "Amoblado", "Depósito", "Portería 24h", "Permite mascotas", "Calefacción", "Aire acondicionado", "Cocina integral"]} placeholder="Nueva característica" />}
        </main>
      </div>
    </div>
  );
}

function UsuariosTab() {
  const [search, setSearch] = useState("");
  const [showDelete, setShowDelete] = useState<number | null>(null);

  const filtered = USUARIOS.filter(u =>
    u.nombre.toLowerCase().includes(search.toLowerCase()) ||
    u.email.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div>
      <div className="flex items-center justify-between mb-6">
        <h1 className="font-display text-2xl font-semibold text-[#243B32]">Usuarios</h1>
        <div className="flex gap-3">
          <input
            placeholder="Buscar usuario..."
            value={search}
            onChange={e => setSearch(e.target.value)}
            className="rounded-lg border border-[#ddd6c8] px-4 py-2 text-sm focus:border-[#C96E4B] focus:outline-none w-56"
          />
          <Btn size="sm">+ Crear usuario</Btn>
        </div>
      </div>
      <div className="overflow-x-auto rounded-2xl border border-[#ddd6c8]">
        <table className="w-full text-sm">
          <thead className="bg-[#E8D8C4]">
            <tr>
              {["Nombre", "Correo", "Rol", "Ciudad", "Estado", "Registro", ""].map(h => (
                <th key={h} className="text-left px-5 py-3.5 font-semibold text-[#243B32] text-xs uppercase tracking-wider whitespace-nowrap">{h}</th>
              ))}
            </tr>
          </thead>
          <tbody className="bg-white divide-y divide-[#f0e8dc]">
            {filtered.map(u => (
              <tr key={u.id} className="hover:bg-[#F7F2E8] transition-colors">
                <td className="px-5 py-3.5">
                  <div className="flex items-center gap-2.5">
                    <div className="w-8 h-8 rounded-full bg-[#243B32] flex items-center justify-center text-white text-xs font-semibold shrink-0">{u.nombre[0]}</div>
                    <span className="font-medium text-[#252525]">{u.nombre}</span>
                  </div>
                </td>
                <td className="px-5 py-3.5 text-[#6b7280]">{u.email}</td>
                <td className="px-5 py-3.5">
                  <Badge label={u.rol} variant={u.rol === "Inmobiliaria" ? "arriendo" : "neutral"} />
                </td>
                <td className="px-5 py-3.5 text-[#6b7280]">{u.ciudad}</td>
                <td className="px-5 py-3.5">
                  <Badge label={u.estado} variant={u.estado === "Activo" ? "success" : "danger"} />
                </td>
                <td className="px-5 py-3.5 text-[#6b7280] text-xs">{u.registro}</td>
                <td className="px-5 py-3.5">
                  <div className="flex gap-1.5">
                    <Btn size="sm" variant="ghost">Editar</Btn>
                    <Btn size="sm" variant="danger" onClick={() => setShowDelete(u.id)}>Eliminar</Btn>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
      {showDelete && (
        <Modal title="Eliminar usuario" onClose={() => setShowDelete(null)}>
          <Alert type="error" message="Esta acción eliminará permanentemente la cuenta y todos sus datos asociados." />
          <div className="flex gap-3 mt-5">
            <Btn variant="ghost" className="flex-1" onClick={() => setShowDelete(null)}>Cancelar</Btn>
            <Btn variant="danger" className="flex-1" onClick={() => setShowDelete(null)}>Eliminar cuenta</Btn>
          </div>
        </Modal>
      )}
    </div>
  );
}

function InmobiliariasTab() {
  return (
    <div>
      <div className="flex items-center justify-between mb-6">
        <h1 className="font-display text-2xl font-semibold text-[#243B32]">Inmobiliarias</h1>
        <Btn size="sm">+ Registrar inmobiliaria</Btn>
      </div>
      <div className="overflow-x-auto rounded-2xl border border-[#ddd6c8]">
        <table className="w-full text-sm">
          <thead className="bg-[#E8D8C4]">
            <tr>
              {["Empresa", "Ciudad", "Plan", "Propiedades", "Estado", "Contacto", ""].map(h => (
                <th key={h} className="text-left px-5 py-3.5 font-semibold text-[#243B32] text-xs uppercase tracking-wider whitespace-nowrap">{h}</th>
              ))}
            </tr>
          </thead>
          <tbody className="bg-white divide-y divide-[#f0e8dc]">
            {INMOBILIARIAS.map(i => (
              <tr key={i.id} className="hover:bg-[#F7F2E8] transition-colors">
                <td className="px-5 py-3.5">
                  <div className="flex items-center gap-2.5">
                    <div className="w-8 h-8 rounded-lg bg-[#243B32] flex items-center justify-center text-white text-xs font-bold shrink-0">{i.nombre[0]}</div>
                    <span className="font-medium text-[#252525]">{i.nombre}</span>
                  </div>
                </td>
                <td className="px-5 py-3.5 text-[#6b7280]">{i.ciudad}</td>
                <td className="px-5 py-3.5">
                  <Badge label={i.plan} variant={i.plan === "Pro" ? "venta" : "neutral"} />
                </td>
                <td className="px-5 py-3.5 text-[#252525] font-medium">{i.propiedades}</td>
                <td className="px-5 py-3.5">
                  <Badge label={i.estado} variant={i.estado === "Activa" ? "success" : "danger"} />
                </td>
                <td className="px-5 py-3.5 text-[#6b7280] text-xs">{i.contacto}</td>
                <td className="px-5 py-3.5">
                  <div className="flex gap-1.5">
                    <Btn size="sm" variant="ghost">Ver</Btn>
                    <Btn size="sm" variant="ghost">Editar</Btn>
                    <Btn size="sm" variant={i.estado === "Activa" ? "danger" : "secondary"}>
                      {i.estado === "Activa" ? "Suspender" : "Activar"}
                    </Btn>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}

function CatalogAdmin({ title, items: initial, placeholder }: { title: string; items: string[]; placeholder: string }) {
  const [items, setItems] = useState(initial);
  const [newItem, setNewItem] = useState("");
  const [editing, setEditing] = useState<number | null>(null);
  const [editVal, setEditVal] = useState("");
  const [success, setSuccess] = useState("");

  function add() {
    if (newItem.trim()) {
      setItems([...items, newItem.trim()]);
      setNewItem("");
      setSuccess(`"${newItem.trim()}" agregado correctamente.`);
      setTimeout(() => setSuccess(""), 3000);
    }
  }

  function remove(i: number) {
    setItems(items.filter((_, idx) => idx !== i));
  }

  function saveEdit(i: number) {
    setItems(items.map((item, idx) => idx === i ? editVal : item));
    setEditing(null);
  }

  return (
    <div className="max-w-2xl">
      <h1 className="font-display text-2xl font-semibold text-[#243B32] mb-6">{title}</h1>
      {success && <div className="mb-5"><Alert type="success" message={success} /></div>}
      <Card className="p-5 mb-5">
        <div className="flex gap-3">
          <input
            placeholder={placeholder}
            value={newItem}
            onChange={e => setNewItem(e.target.value)}
            onKeyDown={e => e.key === "Enter" && add()}
            className="flex-1 rounded-lg border border-[#ddd6c8] px-4 py-2.5 text-sm focus:border-[#C96E4B] focus:outline-none"
          />
          <Btn onClick={add}>Agregar</Btn>
        </div>
      </Card>
      <div className="space-y-2">
        {items.map((item, i) => (
          <Card key={i} className="px-5 py-3 flex items-center gap-3">
            {editing === i ? (
              <>
                <input
                  value={editVal}
                  onChange={e => setEditVal(e.target.value)}
                  className="flex-1 rounded-lg border border-[#C96E4B] px-3 py-1.5 text-sm focus:outline-none"
                  autoFocus
                />
                <Btn size="sm" onClick={() => saveEdit(i)}>Guardar</Btn>
                <Btn size="sm" variant="ghost" onClick={() => setEditing(null)}>Cancelar</Btn>
              </>
            ) : (
              <>
                <span className="flex-1 text-sm text-[#252525] font-medium">{item}</span>
                <Btn size="sm" variant="ghost" onClick={() => { setEditing(i); setEditVal(item); }}>Editar</Btn>
                <Btn size="sm" variant="danger" onClick={() => remove(i)}>Eliminar</Btn>
              </>
            )}
          </Card>
        ))}
      </div>
    </div>
  );
}
