<!-- 1.2.1 -->
<div class="definition reference" id="refdefinitioninversesemigroup">
<p><span class="envidentifier">Definition 1.2.1</span>
A <em>semigroup</em> is a set $S$ endowed with an associative binary operation $(s,t)\mapsto st$. A semigroup is
<ol>
	<li> <em>regular</em> if for every $s\in S$ there exists an element $t\in S$, called an <em>inverse</em> of $s$, satisfying $sts=s$ and $tst=t$.</li>
	<li> an <em>inverse semigroup</em> if it is regular and every $s\in S$ admits a unique inverse. In this case we denote it as $s^*$.
	<li> a <em>monoid</em> if it has an <em>identity</em> or <em>unit</em>, that is, an element $1\in S$ (necessarily unique) satisfying $1s=s1=s$ for all $s\in S$.
</ol>
A <em>subsemigroup</em> of a semigroup $S$ is a subset $T\subseteq S$ which is closed under the semigroup operation. A <em>sub-inverse semigroup</em> of an inverse semigroup is a subsemigroup which is closed under inverses.</p>
</div>

<!-- 1.2.2 -->
<div class="reference definition" id="refdefinitionmorphismofsemigroups">
<p><span class="envidentifier">Definition 1.2.2</span>
A <em>morphism</em> of semigroups is a map $\theta:S\to T$ satisfying $\theta(s_1s_2)=\theta(s_1)\theta(s_2)$ for all $s_1,s_2\in S$. Moreover, $\theta$ is an <em>isomorphism</em> if it is invertible and $\theta^{-1}$ is also a morphism.
</div>

<div class="reference remark" id="refremarksubinversesemigroups">
<p><span class="envidentifier">Remark</span>
If $S$ is an inverse semigroup and $T$ is a subsemigroup which is regular, then every element $t\in T$ admits an inverse $t'\in T$. However since inverses are unique in $S$ then $t'=t^*$. Therefore regular sub-semigroups of inverse semigroups are sub-inverse semigroups.
</p>
</div>

	<!-- 1.2.11 -->
<div class="reference example" id="refexamplebisectionsofequivalencerelationarefunctions">
<p><span class="envidentifier">Example 1.2.11</span>
If $R$ is an equivalence relation on a set $X$ (seen as a principal groupoid), then $\operatorname{\bf Bis}(R)$ can be identified with the subsemigroup of $\mathcal{I}(X)$
<div class="equation">\[
\mathcal{J}=\left\{f\in\mathcal{I}(X):\forall x\in\dom(f), (f(x),x)\in R\right\}.
\]</div>
Indeed, the map $\theta:\operatorname{\bf Bis}(R)\to\mathcal{J}$, given by
<div class="equation">\[
\theta_A=\ra\circ(\so|_A)^{-1}:\so(A)\to\ra(A)
\]</div>
is a semigroup morphism with inverse $f\mapsto\operatorname{graph}(f)$. Whenever necessary, we will identify $\operatorname{\bf Bis}(R)$ with $\mathcal{J}$ in this manner.
</p>
<p>
In particular, if $R=X\times X$ then $\mathcal{J}=\mathcal{I}(X)$, so $\operatorname{Bis}(X\times X)$ is isomorphic to $\mathcal{I}(X)$.
</p>
</div>

<!-- 1.2.12 -->
<div class="reference example" id="refexampleginsidebisectionsoftransformationgroupoid">
<p><span class="envidentifier">Example 1.2.12</span>
If $\theta$ is an action of a group $G$ on a set $X$, then the map $g\mapsto\left\{g\right\}\times X$ is an injective morphism (Definition <a class="makeref" data-target="refdefinitionmorphismofsemigroups" href="#definitionmorphismofsemigroups">1.2.2</a>) of $G$ into $\operatorname{\bf{Bis}}(G\ltimes_\theta X)$.
</p>
</div>

<!-- 1.2.14 -->
<div class="reference example" id="refexampleidempotentssets">
<p><span class="envidentifier">Example 1.2.14</span>
Given a set $A$, let $\id_A:A\to A$ be the identity function of $A$. Then if $X$ is a set, the idempotent set of $\mathcal{I}(X)$ is
<div class="equation">\[
E(\mathcal{I}(X))=\left\{\id_A:A\subseteq X\right\}.
\]</div>
Also note that $\id_{A\cap B}=\id_A\id_B$ whenever $A,B\subseteq X$, so by identifying subsets of $X$ with their respective identity functions, the semigroup operation of $\mathcal{I}(X)$ corresponds to intersection of sets. Moreover, $f^*f=\id_{\dom(f)}$ and $ff^*=\id_{\ran(f)}$, so $f^*f$ corresponds to the domain of $f$ and $ff^*$ corresponds to the range of $f$.
</p>
</div>

<!-- 1.2.15 -->
<div class="reference theorem" id="reftheoreminverseiffescommute">
<p><span class="envidentifier">Theorem 1.2.15 <span style="font-weight:normal;">([<a class="makeref" data-target="refMR0466355" href="../0.matters/references.html#MR0466355">88</a>, Theorem 5.1.2], [<a class="makeref" data-target="refMR1694900" href="../0.matters/references.html#MR1694900">108</a>, Theorem 1.1.3])</span></span>
A regular semigroup $S$ is inverse if and only if the elements of $E(S)$ commute. In this case, $E(S)$ is a sub-inverse semigroup of $S$.
</p>
</div>

<!-- 1.2.16 -->
<div class="reference corollary" id="reftheorempropertiesofinversesinsemigroups">
<p><span class="envidentifier">Corollary 1.2.16</span>
Let $S$ be an inverse semigroup. Then
<ol class="alphpar">
	<li> $(s^*)^*=s$ for all $s\in S$;</li>
	<li> $(st)^*=t^*s^*$ for all $s\in S$;</li>
	<li> If $s\in S$ and $e\in E(S)$ then $ses^*\in E(S)$.</li>
</ol></p>
</div>

<div class="reference equation" id="refequationpartialisometriesinversesemigroup">\[
\Vert x\Vert=\Vert u(x)\Vert=\Vert u(v(u(x)))\Vert\leq\Vert v(u(x))\Vert\leq\Vert u(x)\Vert\leq\Vert x\Vert\tag{1.2.1}
\]</div>

<div class="reference" id="reforderinversesemigroup">
We define a partial order on an inverse semigroup $S$ with any of the following equivalent statements
<div>\begin{align*}
s\leq t&\iff\exists e\in E(S)\left(te=s\right)\iff\exists e\in E(S)(et=s)\\
&\iff s=ts^*s\iff s=ss^*t
\end{align*}</div>
(the equivalence of these statements can be proven using Theorem <a class="makeref" data-target="reftheoreminverseiffescommute" href="#theoreminverseiffescommute">1.2.15</a>).
</div>

<!-- 1.2.22 -->
<div class="reference theorem" id="reftheoremorder">
<p><span class="envidentifier">Theorem 1.2.22
<span style="font-weight:normal;">(See [<a class="makeref" data-target="MR0466355" href="../0.matters/references.html#MR0466355">88</a>, Section 5.2])</span></span>
Let $S$ be an inverse semigroup. Then
<ol class="alphpar">
	<li> $s\leq t$ if and only if $s^*\leq t^*$;</li>
	<li> If $s\leq t$ and $z\in S$ then  $sz\leq tz$ and $zs\leq zt$;</li>
	<li> If $s\in S$, $e\in E(S)$ and $s\leq e$ then $s\in E(S)$;</li>
	<li> If $s\leq t$ then $s^*s=t^*s=s^*t$ and $ss^*=st^*=ts^*$;</li>
	<li> If $s\leq t$ and $s^*s=t^*t$ then $s=t$.</li>
</ol></p>
</div>

<!-- 1.2.23 -->
<div class="reference proposition" id="refpropositionzerosemigroup">
<p><span class="envidentifier">Proposition 1.2.23</span>
An element $p$ of an inverse semigroup $S$ is a zero (minimum) of $S$ if and only if it is absorbing (that is, $ps=p$ for all $s\in S$).
</p>
</div>

<!-- 1.2.25 -->
<div class="reference proposition" id="refpropositionpropertiesofmorphismsofsemigroups">
<p><span class="envidentifier">Proposition 1.2.25</span>
Let $\theta:S\to T$ be a morphism of semigroups.
<ol class="alphpar">
	<li> $\theta(S)$ is a subsemigroup of $T$;</li>
	<li> If $\theta$ is invertible then it is immediately an isomorphism;</li>
	<li> If $S$ is regular then $\theta(S)$ is regular;</li>
	<li> If $S$ is regular and $T$ is an inverse semigroup then $\theta(S)$ is a sub-inverse semigroup of $T$;</li>
	<li> If $S$ is inverse and $\theta$ is surjective, then $\theta(E(S))=E(T)$, and $T$ is an inverse semigroup;</li>
	<li> If $S$ and $T$ are inverse semigroups then $\theta(s^*)=\theta(s)^*$ for all $s\in S$.</li>
</ol>
</p>
</div>

<!-- 1.2.3 -->
<div class="reference example" id="refexamplesemilatticesasinversesemigroups">
<p><span class="envidentifier">Example 1.2.3</span>
Every $\land$-semilattice is an inverse semigroup with the meet as the operation: $xy=x\land y$. In this case, every element is its own inverse: $x^*=x$.
</p>
</div>

<!-- 1.2.26 -->
<div class="reference theorem" id="reftheoremwagnerpreston" data-number="1.2.26">
<p><span class="envidentifier">Theorem 1.2.26
<span style="font-weight:normal;">(Vagner-Preston Theorem, [<a class="makeref" data-target="MR0064038", href="../0.matters/references.html#MR0064038">141</a>,<a class="makeref" data-target="MR0048425", href="../0.matters/references.html#MR0048425">171</a>])</span></span>
Every inverse semigroup $S$ is isomorphic to a sub-inverse semigroup of $\mathcal{I}(X)$ for some set $X$.
</p>
</div>

<!-- 1.2.27 -->
<div class="reference definition" id="refdefinitioncanonicalleftaction">
<p><span class="envidentifier">Definition 1.2.27</span>
The map $\alpha:S\to\mathcal{I}(S)$ is called the <em>canonical left action of $S$ on itself</em>.
<p>
</div>

<!-- 1.2.28 -->
<div class="reference proposition" data-number="1.2.28" id="refpropositionifcommonupperboundthencompatible">
<p><span class="envidentifier">Proposition 1.2.28</span>
Suppose $S$ is an inverse semigroup and $s,t\in S$ admit a common upper bound (that is, there is some $z\in S$ with $s\leq z$ and $t\leq z$). Then $s^*t\in E(S)$ and $st^*\in E(S)$.
</p>
</div>

<!-- 1.2.29 -->
<div class="reference definition" id="refdefinitioncompatibility">
<p><span class="envidentifier">Definition 1.2.29</span>
Two elements $s,t\in S$ are <em>compatible</em> if $s^*t$ and $st^*$ belong to $E(S)$. A subset $F\subseteq S$ is called <em>compatible</em> if any two elements of $F$ are compatible.
</p>
</div>

<!-- 1.2.30 -->
<div class="reference proposition" id="refpropositioncompatibility">
<p><span class="envidentifier">Proposition 1.2.30</span>
Let $S$ be an inverse semigroup, $s,t\in S$ two compatible elements and $z\in S$. Then
<ol class="alphpar">
	<li> $s^*$ and $t^*$ are compatible;</li>
	<li> $zs$ and $zt$ are compatible;</li>
	<li> $s\land t$ exists, and $s\land t=st^*t=tt^*s=ts^*s=ss^*t$.</li>
</ol>
</p>
</div>

<!-- 1.2.33 -->
<div class="reference definition" id="refdefinitiondistributivesemigroup">
<p><span class="envidentifier">Definition 1.2.33 <span style="font-weight:normal;">([<a class="makeref" data-target="MR3077869" href="../0.matters/references.html#MR3077869">88</a>])</span></span>
A \emph{distributive semigroup} is an inverse semigroup $S$ such that any two compatible elements $s,t\in S$ admit a join $s\lor t$, and for every $z\in S$, $z(s\lor t)=(zs)\lor (zt)$.
</p>
</div>

<!-- 1.2.35 -->
<div class="reference example" id="refbisgisinfinitelydistributive">
<p><span class="envidentifier">Example 1.2.35</span>
The semigroup $\operatorname{\bf Bis}(\mathcal{G})$ of bisections of a groupoid $\mathcal{G}$ is distributive. More generally, if $\mathscr{F}$ is any (possibly infinite) compatible subset of $\operatorname{\bf Bis}(\mathcal{G})$, then the join of $\mathscr{F}$ exists and coincides with the union of its elements:
<div class="equation">\[
\bigvee\mathscr{F}=\bigcup\mathscr{F}=\bigcup_{A\in\mathscr{F}}A.
\]</div>
</p>

<p>
Moreover, in this case we have $A(\bigvee \mathscr{F})=\bigvee(A\mathscr{F})$ for any $A\in\operatorname{\bf Bis}(\mathcal{G})$. We say that $\operatorname{\bf Bis}(\mathcal{G})$ is <em>infinitely distributive</em> ([<a class="makeref" data-target="MR2277324" href="../0.matters/references.html#MR2277324">150</a>]). (Cf. Definition <a class="makeref" data-target="refdefinitionkappadistributivesemigroup" href="#definitionkappadistributivesemigroup">1.2.40</a>.)
</p>
</div>

<!-- 1.2.36 -->
<div class="reference example" id="refexampleixisinfinitelydistributive">
<p><span class="envidentifier">Example 1.2.36</span>
	If $X$ is a set then, by Example <a class="makeref" data-target="refexamplebisectionsofequivalencerelationarefunctions" href="#examplebisectionsofequivalencerelationarefunctions">1.2.11</a>, $\mathcal{I}(X)$ is isomorphic to $\operatorname{\bf Bis}(X\times X)$, and thus it is (infinitely) distributive by Example <a class="makeref" data-target="refbisgisinfinitelydistributive"href="#bisgisinfinitelydistributive">1.2.35</a> above. If $\mathscr{F}$ is any compatible subset of $\mathcal{I}(X)$, then the join of $\mathscr{F}$ is the function given by
	<div class="equation">\[
	\bigvee \mathscr{F}:\bigcup_{f\in F}\dom(f)\to\bigcup_{f\in F}\ran(f),\qquad \left(\bigvee \mathscr{F}\right)(x)=f(x),
	\]</div>
	where $f\in \mathscr{F}$ is chosen such that $x\in\dom(f)$ ("$\dom$" and "$\ran$" stand for the domain and range of an element of $\mathcal{I}(X)$).
	</p>
</div>

<!-- 1.2.37 -->
<div class="reference proposition" id="refpropositionpropertiesofjoins">
<p><span class="envidentifier">Proposition 1.2.37</span>
Let $S$ be an inverse semigroup.
<ol class="alphpar">
	<li> If $F\subseteq E(S)$ admits a join, then $\bigvee F\in E(S)$;</li>
	<li> If $F\subseteq S$ admits a join, then $F^*$ also admits a join, namely $\bigvee(F^*)=\left(\bigvee F\right)^*$.</li>
</ol></p>
</div>

<!-- 1.2.39 -->
<div class="reference proposition" id="refpropositionfinitarydistributivityofdistributivesemigroups">
<p><span class="envidentifier">Proposition 1.2.39</span>
If $S$ is a distributive semigroup, then every finite nonempty compatible set $F\subseteq S$ admits a join, and for every $t\in S$,
<div class="equation">\[
\bigvee(tF)=t\left(\bigvee F\right)\quad\text{and}\quad\bigvee (Ft)=\left(\bigvee F\right)t.
\]</div>
</p>
</div>

<!-- 1.2.40 -->
<div class="reference definition" id="refdefinitionkappadistributivesemigroup">
<p><span class="envidentifier">Definition 1.2.40
<span style="font-weight:normal;">([<a class="makeref" data-target="MR1940513" href="../0.matters/references.html#MR1940513">93</a>, p. 82])</span></span>
Let $\kappa$ be a cardinal. An inverse semigroup $S$ is <em>$\kappa$-distributive</em> if for every compatible set $F\subseteq S$ with $|F|<\kappa$, the supremum $\bigvee F$ exists and for all $z\in S$,
<div class="equation"\[
z\left(\bigvee F\right)=\bigvee(zF).
\]</div>
Note that $|zF|\leq |F|$ and $zF$ is compatible by Proposition <a class="makeref" data-target="refpropositioncompatibility" href="#propositioncompatibility">1.2.30</a>, and that $\left(\bigvee F\right)z=\bigvee(Fz)$ also holds by Proposition <a class="makeref" data-target="refpropositionpropertiesofjoins" href="#propositionpropertiesofjoins">1.2.37</a>(b).
</p>
</div>