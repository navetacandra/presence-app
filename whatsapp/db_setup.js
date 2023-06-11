require('dotenv').config();
const { initializeApp } = require('firebase/app');
const { getDatabase, update, remove, ref } = require('firebase/database');

const app = initializeApp(JSON.parse(process.env.FCONFIG));
const db = getDatabase(app);

const obj = {};
const tgl_obj = {};

const template_detail = {
    jam_hadir_start: "00:01",
    jam_hadir_end: "06:45",
    jam_pulang_start: "15:00",
    jam_pulang_end: "23:00",
}

Array(31).fill(0).map((_, i) => {
    tgl_obj[i+1] = {
        pegawai: [],
        mode: true,
        active: true,
        ...template_detail
    }
})

const b = [
    'januari',
    'februari',
    'maret',
    'april',
    'mei',
    'juni',
    'juli',
    'agustus',
    'september',
    'oktober',
    'november',
    'desember',
].forEach(e => { obj[e] = tgl_obj });



// console.log(obj);
update(ref(db, "absen_detail"), template_detail)
update(ref(db, "absensi"), obj)