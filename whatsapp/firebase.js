const { initializeApp } = require('firebase/app');
const { getAuth, signInWithEmailAndPassword, createUserWithEmailAndPassword, deleteUser, signOut } = require('firebase/auth');
const { getDatabase, onChildAdded, update, remove, get, ref, query, orderByChild, equalTo, onChildChanged, onValue, set } = require('firebase/database');
const { AES, enc } = require('crypto-js');
require('dotenv').config();

class Firebase {
    constructor() {
        this.encryptionAlgorithm = 'aes-256-cbc';
        this.encryptionKey = 'presence key';
        this.mainEmail = process.env.EMAIL;
        this.mainPassword = process.env.PASS;
        this.mainApp = initializeApp(JSON.parse(process.env.FCONFIG));
        this.authApp = getAuth(this.mainApp);
        this.dbApp = getDatabase(this.mainApp);
        this.MOBJ = {};

        const tgl_obj = {};
        Array(31).fill(0).map((_, i) => {
            tgl_obj[i + 1] = {}
        });
        [
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
        ].forEach(e => { this.MOBJ[e] = tgl_obj });

        this.#setup();
    }

    async #setup() {
        await signOut(this.authApp);
        signInWithEmailAndPassword(this.authApp, this.mainEmail, this.mainPassword)
            .then(() => {
                this.streamMode();
                this.streamDetail();
            })
            .catch(err => console.log(err));
    }

    async createAccount(name, email, pass) {
        try {
            await signOut(this.authApp);
            signInWithEmailAndPassword(this.authApp, this.mainEmail, this.mainPassword).catch(err => console.log(err));
            const u = await createUserWithEmailAndPassword(this.authApp, email, pass);
            await update(ref(this.dbApp, `users/${u.user.uid}`), {
                name, email, uid: u.user.uid, password: AES.encrypt(pass, this.encryptionKey).toString(), role: 3,
            })
            await signOut(this.authApp);
            signInWithEmailAndPassword(this.authApp, this.mainEmail, this.mainPassword).catch(err => console.log(err));
            return {
                code: 200, response: u,
            }
        } catch (err) {
            return {
                code: 400,
                response: err.code,
            }
        }
    }

    async deleteAccount(email) {
        await signOut(this.authApp);
        await signInWithEmailAndPassword(this.authApp, this.mainEmail, this.mainPassword);
        const target = await get(query(ref(this.dbApp, `users/`), orderByChild('email'), equalTo(email)));
        if (!target.exists()) {
            return {
                code: 404,
                response: 'user-not-found',
            }
        }

        const targetPass = AES.decrypt(Object.values(target.val())[0].password, this.encryptionKey).toString(enc.Utf8);
        try {
            await signOut(this.authApp);
            const u = await signInWithEmailAndPassword(this.authApp, email, targetPass);
            await deleteUser(u.user)
            await signOut(this.authApp);
            await signInWithEmailAndPassword(this.authApp, this.mainEmail, this.mainPassword);
            await remove(ref(this.dbApp, `users/${Object.keys(target.val())[0]}`))
            return {
                code: 200,
                response: `${email}-was-deleted`
            }
        } catch (err) {
            return {
                code: 400,
                response: err.code,
            }
        }
    }

    streamDetail() {
        onValue(ref(this.dbApp, 'absen_detail'), snap => {
            [
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
            ].forEach(mth => {
                Array(31).fill(0).map((_, i) => i + 1).forEach(dy => {
                    update(ref(this.dbApp, `absensi/${mth}/${dy}`), snap.val());
                })
            })
        })
    }

    streamMode() {
        onValue(ref(this.dbApp, 'mode'), snap => {
            [
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
            ].forEach(mth => {
                Array(31).fill(0).map((_, i) => i + 1).forEach(dy => {
                    update(ref(this.dbApp, `absensi/${mth}/${dy}`), {[snap.key]: snap.val()});
                })
            })
        })
    }
}

module.exports = new Firebase();